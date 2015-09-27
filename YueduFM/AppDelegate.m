//
//  AppDelegate.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MenuViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [__serviceCenter setup];
    
    [self setupAppearance];
    
    MainViewController* mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    nvc.navigationBar.translucent = YES;
    nvc.navigationBar.barTintColor = kThemeColor;
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    [nvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    nvc.navigationBar.barStyle = UIBarStyleBlack;
    MenuViewController* vc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    
    RESideMenu* sideMenu = [[RESideMenu alloc] initWithContentViewController:nvc leftMenuViewController:vc rightMenuViewController:nil];
    
    [PlayerBar setContainer:sideMenu.view];

    self.window.rootViewController = sideMenu;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupAppearance {
    [[UIBarButtonItem appearance] setTintColor:kThemeColor];
    UIImage* image = [[UIImage imageNamed:@"icon_navigation_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [__serviceCenter stopAllServices];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [__serviceCenter startAllServices];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
//    self.backgroundTransferCompletionHandler = completionHandler;
}

@end
