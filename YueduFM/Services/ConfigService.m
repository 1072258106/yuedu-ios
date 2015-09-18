//
//  ConfigService.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ConfigService.h"

@implementation ServiceCenter (ConfigService)

CATEGORY_PROPERTY_GET_SET_BOOL(BOOL, beConfiged, setBeConfiged:);

- (YDSDKManager* )netManager {
    return [YDSDKManager defaultManager];
}

- (void)configCheckout:(void(^)(NSError* error))completion {
    
}

- (void)configFetch:(void(^)(NSError* error))completion {
    YDSDKConfigRequest* req = [YDSDKConfigRequest request];
    [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
        if (!error) {
            BOOL configed = (self.netManager.config != nil);
            self.netManager.config = req.model;
            if (!configed) {
                self.beConfiged = !configed;                
            }
        }
        if (completion) {
            completion(error);
        }
    }];
}

@end

@implementation ConfigService

- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [serviceCenter.dataManager registerClass:[YDSDKConfigModel class] complete:nil];
    }
    return self;
}

- (void)start {
    [self.serviceCenter configCheckout:nil];
    [self.serviceCenter configFetch:nil];
}

@end
