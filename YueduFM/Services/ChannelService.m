//
//  ChannelService.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ChannelService.h"

@implementation ServiceCenter (ChannelService)

CATEGORY_PROPERTY_GET_SET(NSArray*, channelArray, setChannelArray:);

- (void)channelCheckout:(void(^)(NSError* error))completion {
    [self.dataManager read:[YDSDKChannelModel class] condition:nil complete:^(BOOL successed, id result) {
        if (completion) {
        }
    }];
}

- (void)channelFetch:(void(^)(NSError* error))completion {
    YDSDKChannelListRequest* req = [YDSDKChannelListRequest request];
    [self.netManager request:req completion:^(YDSDKRequest *request, YDSDKError *error) {
        if (!error) {
            self.channelArray = req.modelArray;
        }
        if (completion) {
            completion(error);
        }
    }];
}

@end


@implementation ChannelService

- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        [serviceCenter.dataManager registerClass:[YDSDKChannelModel class] complete:nil];

        [self bk_addObserverForKeyPath:@keypath(serviceCenter.beConfiged) task:^(id target) {
            [serviceCenter channelFetch:nil];
        }];
    }
    return self;
}

@end
