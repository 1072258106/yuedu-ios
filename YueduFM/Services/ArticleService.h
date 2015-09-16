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

- (void)articleFetch:(NSInteger)articleId completion:(void(^)(YDSDKArticleModel* model, NSError* error))completion;

@end

@interface ArticleService : BaseService

@end
