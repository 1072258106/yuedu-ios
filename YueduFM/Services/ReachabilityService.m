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

- (NSString* )statusString {
    switch (self.status) {
        case NotReachable:
            return @"当前无网络连接";
        case ReachableViaWiFi:
            return @"当前网络处于WiFi下, 您可以尽情的收听下载~";
        case ReachableViaWWAN:
            return @"当前网络处于2G/3G/4G下, 请注意流量使用情况哦~";
        default:
            break;
    }
    return nil;
}

- (void)reachabilityChangedNotification:(NSNotification* )notification {
    Reachability* reach = notification.object;
    self.status = reach.currentReachabilityStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showInfoWithStatus:self.statusString];
    });
}

@end
