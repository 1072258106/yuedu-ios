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
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
        configuration.HTTPMaximumConnectionsPerHost = 1;
        
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_queue];
        [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            ArticleService* service = SRV(ArticleService);
            [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSURLSessionTask* task = obj;
                [service modelForAudioURLString:task.originalRequest.URL.absoluteString completion:^(YDSDKArticleModelEx *model) {
                    task.articleModel = model;
                }];
            }];
        }];
        
        _baseDirectory = [NSString stringWithFormat:@"%@/Documents/Dowloads", NSHomeDirectory()];
        [[NSFileManager defaultManager] createDirectoryAtPath:_baseDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}

- (void)state:(void(^)(BOOL downloading))completion {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (completion) {
            completion([downloadTasks count] != 0);
        }
    }];
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
                            || [tk.originalRequest.URL.absoluteString isEqualToString:model.url]) {
                            downloading = YES;
                        }
                    }];
                    
                    NSError* error;
                    if (!downloading) {
                        NSURLSessionDownloadTask* task = [_session downloadTaskWithURL:model.audioURL.url];
                        task.articleModel = newModel;
                        [task resume];
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
    NSLog(@"====ERROR=====%@", error);
    if (error) {
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
    NSLog(@"write[%@][%d]:%@", error, [[NSFileManager defaultManager] fileExistsAtPath:location.absoluteString], URLString);
    if (!error) {
        YDSDKArticleModelEx* model = downloadTask.articleModel;
        model.downloadState = DownloadStateSuccessed;
        model.downloadURLString = URLString;
        NSLog(@"======WRITE:%@", model);
        [SRV(DataService) writeData:model completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSeriviceDidChangedNotification object:nil];
        }];
    } else {
        [self download:downloadTask.articleModel preprocess:nil];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"=====================down:[%lld-%lld]", totalBytesWritten, totalBytesExpectedToWrite);

}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"=====================resume:[%lld-%lld]", fileOffset, expectedTotalBytes);
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

- (void)deleteAllTask:(void(^)())completion {
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [downloadTasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionTask* task = obj;
            [task cancel];
        }];
        
        if (completion) {
            completion();
        }
    }];
}

@end
