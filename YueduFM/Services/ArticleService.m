//
//  ArticleService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleService.h"
#import "YDSDKArticleModelEx.h"

@implementation ArticleService
- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [self.dataManager registerClass:[YDSDKArticleModelEx class] complete:nil];
    }
    return self;
}

- (void)start {
    [self autoFetch];
}

- (void)autoFetch {
    [self.dataManager read:[YDSDKArticleModelEx class] condition:[NSString stringWithFormat:@"state=%d ORDER BY aid DESC LIMIT 0,1", YDSDKModelStateIncomplete] complete:^(BOOL successed, id result) {
        if (successed && [result count]) {
            YDSDKArticleModelEx* model = [result firstObject];
            
            [self fetch:model.aid completion:^(NSError *error) {
                [self autoFetch];
            }];
        }
    }];
}

- (void)checkout:(int)count
         channel:(int)channel
      completion:(void(^)(NSArray* array))completion {
    [self.dataManager read:[YDSDKArticleModelEx class] condition:[NSString stringWithFormat:@"state=%d and channel=%d ORDER BY aid DESC LIMIT 0, %d", YDSDKModelStateNormal, channel, count] complete:^(BOOL successed, id result) {
        if (!self.activeArticleModel && successed) {
            self.activeArticleModel = [result firstObject];
        }
        if (completion) completion(successed?result:nil);
     }];
}

- (void)fetchLatest:(void(^)(NSError* error))completion {
    [self fetch:0 completion:^(NSError *error) {
        [self autoFetch];
        if (completion) {
            completion(error);
        }
    }];
}

- (void)list:(int)count
     channel:(int)channel
  completion:(void (^)(NSArray* array))completion {
    [self checkout:count channel:channel completion:completion];
}

- (void)fetch:(int)articleId completion:(void(^)(NSError* error))completion {
    [SRV(ConfigService) fetch:^(NSError *error) {
        YDSDKArticleListRequest* req = [YDSDKArticleListRequest request];
        req.articleId = articleId;
        [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
            if (!error) {
                self.activeArticleModel = [req.modelArray firstObject];
                
                YDSDKArticleModel* cursorModel = [[YDSDKArticleModel alloc] init];
                cursorModel.aid = articleId;
                
                NSMutableArray* data = [NSMutableArray arrayWithArray:req.modelArray];
                [self.dataManager deleteObject:cursorModel complete:^(BOOL successed, id result) {
                    void(^writeBlock)(NSArray* array) = ^(NSArray* array){
                        [self.dataManager writeObjects:array complete:^(BOOL successed, id result) {
                            if (completion) completion(nil);
                        }];
                    };
                    
                    if (req.next) {
                        YDSDKArticleModelEx* nextModel = [[YDSDKArticleModelEx alloc] init];
                        nextModel.aid = req.next;
                        nextModel.state = YDSDKModelStateIncomplete;
                        [self.dataManager isExist:nextModel complete:^(BOOL successed, id result) {
                            if (!successed) [data addObject:nextModel];
                            writeBlock(data);
                        }];
                    } else {
                        writeBlock(data);
                    }
                }];
            }
        }];        
    }];
}

@end
