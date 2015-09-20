//
//  ArticleService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleService.h"


@implementation ServiceCenter (ArticleService)

CATEGORY_PROPERTY_GET_SET(YDSDKArticleModel*, currentArticleModel, setCurrentArticleModel:)

- (void)articleFetch:(int)articleId completion:(void(^)(NSArray* array, NSError* error))completion {
    YDSDKArticleListRequest* req = [YDSDKArticleListRequest request];
    req.articleId = articleId;
    [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
        if (!error) {
            self.currentArticleModel = [req.modelArray firstObject];
            [self.dataManager writeObjects:req.modelArray complete:^(BOOL successed, id result) {
                
            }];
        }
        
        if (completion) {
            completion(req.modelArray, error);
        }
    }];
}

- (void)articleFetchLatest:(void(^)(NSArray* array, NSError* error))completion {
    [self configFetch:^(NSError* error) {
        [self articleFetch:0 completion:completion];
    }];
}

- (void)articlePlay:(YDSDKArticleModel* )model statusChanged:(void(^)(DOUAudioStreamerStatus status))statusChanged {
    self.audioStreamer = [[DOUAudioStreamer alloc] initWithAudioFile:model.audioURL.url];
    
    [self.audioStreamer bk_removeAllBlockObservers];
    [self.audioStreamer bk_addObserverForKeyPath:@"status" task:^(id target) {
        if (statusChanged) {
            statusChanged(self.audioStreamer.status);
        }
    }];
    
    [self.audioStreamer play];
    self.currentArticleModel = model;
}

- (void)articlePause {
    [self.audioStreamer pause];
}

- (void)articleStop {
    [self.audioStreamer stop];
}

@end

@implementation ArticleService
- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [serviceCenter.dataManager registerClass:[YDSDKArticleModel class] complete:nil];
        
        [self bk_addObserverForKeyPath:@keypath(serviceCenter.beConfiged) task:^(id target) {
//            [serviceCenter articleFetchLatest:nil];
        }];
    }
    return self;
}
@end
