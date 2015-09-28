//
//  ReachabilityService.m
//  YueduFM
//
//  Created by StarNet on 9/27/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ReachabilityService.h"

@interface ReachabilityService () {
    Reachability* _reach;
}

@end

@implementation ReachabilityService

+ (ServiceLevel)level {
    return ServiceLevelHighest;
}

- (instancetype)initWithServiceCenter:(ServiceCenter *)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        _reach = [Reachability reachabilityForInternetConnection];
        [_reach startNotifier];
        self.status = _reach.currentReachabilityStatus;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)reachabilityChangedNotification:(NSNotification* )notification {
    Reachability* reach = notification.object;
    self.status = reach.currentReachabilityStatus;
}

@end
