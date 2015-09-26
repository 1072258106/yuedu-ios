//
//  ArticleService.h
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"

@interface ArticleService : BaseService

@property (nonatomic, strong) YDSDKArticleModel* activeArticleModel;

- (void)fetchLatest:(void(^)(NSError* error))completion;

- (void)list:(int)count
     channel:(int)channel
  completion:(void (^)(NSArray* array))completion;

- (void)listFavored:(int)count completion:(void (^)(NSArray* array))completion;

- (void)listDownloaded:(int)count completion:(void (^)(NSArray* array))completion;

@end
