//
//  DownloadService.m
//  YueduFM
//
//  Created by StarNet on 9/26/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "DownloadService.h"

NSString* const DownloadSeriviceDidChangedNotification = @"DownloadSeriviceDidChangedNotification";

@implementation NSURLSessionTask (DownloadService)

CATEGORY_PROPERTY_GET_SET(YDSDKArticleModelEx*, articleModel, setArticleModel:)

@end

NSString* const DownloadErrorDomain = @"DownloadErrorDomain";

#pragma mark - DownloadService
@interface DownloadService () <NSURLSessionDownloadDelegate> {
    NSURLSession*       _session;
    NSOperationQueue*   _queue;
    NSString*           _baseDirectory;
}

@end

@implementation DownloadService

- (instancetype)initWithServiceCenter:(ServiceCenter *)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [self setupURLSession];
        [self setupDirectory];
        [self setupTasks];
    }
    return self;
}

- (void)setupURLSession {
    NSURLSessionConfiguration* configuration;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    } else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:[[NSBundle mainBundle] bundleIdentifier]];
    }
    configuration.HTTPMaximumConnectionsPerHost = 1;
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_queue];
}

- (void)setupDirectory {
    _baseDirectory = [NSString stringWithFormat:@"%@/Documents/Dowloads", NSHomeDirectory()];
    [[NSFileManager defaultManager] createDirectoryAtPath:_baseDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)setupTasks {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        ArticleService* service = SRV(ArticleService);
        [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionTask* task = obj;
            [service modelForAudioURLString:task.originalRequest.URL.absoluteString completion:^(YDSDKArticleModelEx *model) {
                task.articleModel = model;
            }];
        }];
        
        //空任务，则从数据库读取
        if (![downloadTasks count]) {
            [service listAllDownloading:^(NSArray *array) {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [self download:obj preprocess:nil];
                }];
            }];
        }
    }];
}

- (void)state:(void(^)(BOOL downloading))completion {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (completion) {
            completion([downloadTasks count] != 0);
        }
    }];
}

- (void)didDownload:(YDSDKArticleModelEx* )model {
    NSURLSessionDownloadTask* task = [_session downloadTaskWithURL:model.audioURL.url];
    task.articleModel = model;
    [task resume];
    model.downloadState = DownloadStateDoing;
    [SRV(DataService) writeData:model completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSeriviceDidChangedNotification object:nil];
}

- (void)download:(YDSDKArticleModelEx* )model preprocess:(void(^)(NSError* error))preprocess{
    [SRV(ArticleService) update:model completion:^(YDSDKArticleModelEx *newModel) {
        @synchronized(self) {
            if (newModel.downloadState == DownloadStateSuccessed) {
                if (preprocess) {
                    preprocess([NSError errorWithDomain:DownloadErrorDomain code:DownloadErrorCodeAlreadyDownloaded userInfo:nil]);
                }
            } else {
                [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                    __block BOOL downloading = NO;
                    [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSURLSessionDownloadTask* tk = obj;
                        YDSDKArticleModelEx* aModel = tk.articleModel;
                        if ((aModel == model)
                            || [tk.originalRequest.URL.absoluteString isEqualToString:model.audioURL]) {
                            downloading = YES;
                            *stop = YES;
                        }
                    }];
                    
                    NSError* error;
                    if (!downloading) {
                        [self didDownload:model];
                    } else {
                        error = [NSError errorWithDomain:DownloadErrorDomain code:DownloadErrorCodeAlreadyDownloading userInfo:nil];
                    }
                    
                    if (preprocess) {
                        preprocess(error);
                    }
                }];
            }
        }
    }];
}

- (NSString* )URLStringWithTask:(NSURLSessionDownloadTask* )task {
    return [NSString stringWithFormat:@"%@/%@", _baseDirectory, task.articleModel.audioURL.lastPathComponent];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSeriviceDidChangedNotification object:nil];
    if (error && task.articleModel.downloadState != DownloadStateCanceled) {
        [self download:task.articleModel preprocess:nil];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSError* error;
    NSString* URLString = [self URLStringWithTask:downloadTask];
    [[NSFileManager defaultManager] removeItemAtPath:URLString error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:URLString] error:&error];

    if (!error) {
        YDSDKArticleModelEx* model = downloadTask.articleModel;
        model.downloadState = DownloadStateSuccessed;
        model.downloadURLString = URLString;
        [SRV(DataService) writeData:model completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSeriviceDidChangedNotification object:nil];
        }];
    } else if (downloadTask.articleModel.downloadState != DownloadStateCanceled) {
        [self download:downloadTask.articleModel preprocess:nil];
    }
}

static NSInteger compareTask(id obj1, id obj2, void* context) {
    NSURLSessionTask* task1 = obj1;
    NSURLSessionTask* task2 = obj2;
    
    if (task1.taskIdentifier > task2.taskIdentifier) {
        return NSOrderedDescending;
    } else if (task1.taskIdentifier == task2.taskIdentifier) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending;
    }
}

- (void)list:(void(^)(NSArray* tasks))completion {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSMutableArray* array = [NSMutableArray array];
        [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionTask* task = obj;
            if((task.state == NSURLSessionTaskStateRunning)||(task.state == NSURLSessionTaskStateSuspended)) {
                [array addObject:task];
            }
        }];
        
        if (completion) {
            completion([array sortedArrayUsingFunction:compareTask context:nil]);
        }
    }];
}

- (void)deleteTask:(NSURLSessionTask* )task {
    [task cancel];
    task.articleModel.downloadState = DownloadStateCanceled;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSeriviceDidChangedNotification object:nil];
    [SRV(DataService) writeData:task.articleModel completion:nil];
}

- (void)deleteAllTask:(void(^)())completion {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionTask* task = obj;
            task.articleModel.downloadState = DownloadStateCanceled;
            [task cancel];
            [SRV(DataService) writeData:task.articleModel completion:nil];
        }];
        
        if (completion) {
            completion();
        }
    }];
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (_session != session) return;
    
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count] == 0) {
            if (self.backgroundTransferCompletionHandler != nil) {
                void(^completionHandler)() = self.backgroundTransferCompletionHandler;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler();
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"文章已下载完成.";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
                self.backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}
@end
