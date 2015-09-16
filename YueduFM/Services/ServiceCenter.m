//
//  ServiceCenter.m
//  IntelliCommunity
//
//  Created by Diana on 12/11/14.
//  Copyright (c) 2014 evideo. All rights reserved.
//

#import "ServiceCenter.h"
#import "BaseService.h"

@interface ServiceCenter() {
    NSMutableArray* _serviceArray;
}
@end

@implementation ServiceCenter

+ (instancetype)defaultCenter {
    static ServiceCenter* center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[ServiceCenter alloc] init];
    });
    return center;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceArray = [NSMutableArray array];
    }
    return self;
}

- (void)setup {
    NSArray* classes = [BaseService allSubclasses];
    for (Class cls in classes) {
        BaseService* service = [[cls alloc] initWithServiceCenter:self];
        [_serviceArray addObject:service];
    }
}

- (void)teardown {
    for (BaseService* service in _serviceArray) {
        [service stop];
    }
    
    [_serviceArray removeAllObjects];
}

- (void)startAllServices
{
    for (BaseService* service in _serviceArray) {
        [service start];
    }
}

- (void)stopAllServices
{
    for (BaseService* service in _serviceArray) {
        [service stop];
    }
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    BOOL isHandle = NO;
    for (BaseService* service in _serviceArray) {
        if ([service application:application handleOpenURL:url])
            isHandle = YES;
    }
    return isHandle;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    BOOL isHandle = NO;
    for (BaseService* service in _serviceArray) {
        if ([service application:application openURL:url sourceApplication:sourceApplication annotation:annotation])
                isHandle = YES;
    }
    return isHandle;
}
@end
