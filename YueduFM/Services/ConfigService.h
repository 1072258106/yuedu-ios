//
//  ConfigService.h
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"
#import <YueduFMSDK/YueduFMSDK.h>

@interface ServiceCenter (ConfigService)

@property (nonatomic, assign) BOOL beConfiged;

- (YDSDKManager* )netManager;

- (void)configFetch:(void(^)(NSError* error))completion;

@end

@interface ConfigService : BaseService


@end
