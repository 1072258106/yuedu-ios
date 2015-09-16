//
//  ArticleService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleService.h"


@implementation ServiceCenter (ArticleService)

- (void)articleFetch:(NSInteger)articleId completion:(void(^)(YDSDKArticleModel* model, NSError* error))completion {
    YDSDKArticleRequest* req = [YDSDKArticleRequest request];
    req.articleId = articleId;
    [[YDSDKManager defaultManager] request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
        if (completion) {
            completion(req.model ,error);
        }
    }];
}

@end

@implementation ArticleService

@end
