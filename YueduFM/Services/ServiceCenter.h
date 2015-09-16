//
//  ServiceCenter.h
//  IntelliCommunity
//
//  Created by Diana on 12/11/14.
//  Copyright (c) 2014 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define __serviceCenter [ServiceCenter defaultCenter]

@interface ServiceCenter : NSObject
@property (nonatomic, strong) NSString* version;

+ (instancetype)defaultCenter;

/**
 * 启动服务，用于启动所有的Serivce服务
 *
 */
- (void)startAllServices;


/**
 * 关闭服务，用于关闭所有的Serivce服务
 *
 */
- (void)stopAllServices;

- (void)setup;

- (void)teardown;

- (BOOL)application:(UIApplication *)application
              handleOpenURL:(NSURL *)url;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;
@end
