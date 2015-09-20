//
//  ArticleService.h
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"
#import <YueduFMSDK/YueduFMSDK.h>

@interface ServiceCenter (ArticleService)

@property (nonatomic, strong) YDSDKArticleModel* currentArticleModel;

- (void)articleFetch:(int)articleId completion:(void(^)(NSArray* array, NSError* error))completion;
- (void)articleFetchLatest:(void(^)(NSArray* array, NSError* error))completion;

- (void)articlePlay:(YDSDKArticleModel* )model statusChanged:(void(^)(DOUAudioStreamerStatus status))statusChanged;

- (void)articlePause;

- (void)articleStop;
@end

@interface ArticleService : BaseService

@end
