//
//  ConfigService.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ConfigService.h"

@interface ConfigService () {
    NSMutableArray* _blockArray;
}

@end

@implementation ConfigService

+ (ServiceLevel)level {
    return ServiceLevelMiddle;
}

- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        _blockArray = [NSMutableArray array];
        [self.dataManager registerClass:[YDSDKConfigModelEx class] complete:nil];
        [self checkout:nil];
    }
    return self;
}

- (void)checkout:(void(^)(BOOL successed))completion {
    [self.dataManager read:[YDSDKConfigModelEx class] condition:nil complete:^(BOOL successed, id result) {
        self.netManager.config = successed?[result firstObject]:nil;
        self.config = successed?[result firstObject]:nil;
        self.isConfiged = YES;
        if (completion) completion(successed);
    }];
}

- (void)fetch:(void(^)(NSError* error))completion {
    //为了避免过多访问服务器，同一天不更新config
    if (self.config && [self.config.updateDate isSameDay:[NSDate date]]) {
        if (completion) completion(nil);
    } else {
        YDSDKConfigRequest* req = [YDSDKConfigRequest request];
        [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
            if (!error) {
                YDSDKConfigModelEx* model = [YDSDKConfigModelEx objectFromSuperObject:req.model];
                model.updateDate = [NSDate date];
                [self.dataManager writeObject:model complete:^(BOOL successed, id result) {
                    [self checkout:^(BOOL successed){
                        if (completion) completion(error);
                    }];
                }];
            } else {
                if (completion) completion(error);
            }
        }];
    }
}

@end
