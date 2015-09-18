//
//  ArticleService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleService.h"


@implementation ServiceCenter (ArticleService)

- (void)articleFetch:(int)articleId completion:(void(^)(NSArray* array, NSError* error))completion {
    YDSDKArticleListRequest* req = [YDSDKArticleListRequest request];
    req.articleId = articleId;
    [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
        if (!error) {
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

@end

@implementation ArticleService
- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [serviceCenter.dataManager registerClass:[YDSDKArticleModel class] complete:nil];
        
        [self bk_addObserverForKeyPath:@keypath(serviceCenter.beConfiged) task:^(id target) {
            [serviceCenter articleFetchLatest:nil];
        }];
    }
    return self;
}
@end
