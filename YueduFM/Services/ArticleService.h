//
//  ArticleService.h
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"

@class YDSDKArticleModelEx;

@interface ArticleService : BaseService
@property (nonatomic, strong) YDSDKArticleModelEx* activeArticleModel;

- (void)fetchLatest:(void(^)(NSError* error))completion;

- (void)list:(int)count
     channel:(int)channel
  completion:(void (^)(NSArray* array))completion;

- (void)listFavored:(int)count completion:(void (^)(NSArray* array))completion;

- (void)listDownloaded:(int)count completion:(void (^)(NSArray* array))completion;

- (void)modelForAudioURLString:(NSString* )URLString completion:(void(^)(YDSDKArticleModelEx* model))completion;

- (void)deleteDownloaded:(YDSDKArticleModelEx* )model completion:(void (^)(BOOL successed))completion;

- (void)deleteAllDownloaded:(void (^)())completion;

- (void)update:(YDSDKArticleModelEx* )model completion:(void(^)(YDSDKArticleModelEx* newModel))completion;

@end
