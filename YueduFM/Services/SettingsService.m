//
//  SettingsService.m
//  YueduFM
//
//  Created by StarNet on 9/27/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "SettingsService.h"

@interface SettingsService () {
}

@end

@implementation SettingsService

+ (ServiceLevel)level {
    return ServiceLevelHighest;
}

- (instancetype)initWithServiceCenter:(ServiceCenter *)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        _flowProtection = YES;
        [self setup];
    }
    return self;
}

- (void)setup {
    //流量
    id value = USER_CONFIG(@"flowProtection");
    _flowProtection = value?[value boolValue]:YES;
    
    //自动关闭
    _autoCloseTimes = @[
                        @(0),
                        @(10),
                        @(20),
                        @(30),
                        @(60),
                        @(120)
                        ];
    
    _autoCloseLevel = [USER_CONFIG(@"autoCloseLevel") integerValue];
}

- (void)setFlowProtection:(BOOL)flowProtection {
    _flowProtection = flowProtection;
    USER_SET_CONFIG(@"flowProtection", @(flowProtection));
}

- (void)setAutoCloseLevel:(NSInteger)autoCloseLevel {
    _autoCloseLevel = autoCloseLevel;
    USER_SET_CONFIG(@"autoCloseLevel", @(_autoCloseLevel));
}

@end
