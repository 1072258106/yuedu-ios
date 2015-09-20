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
    
    MainViewController* mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    nvc.navigationBar.translucent = YES;
    nvc.navigationBar.barTintColor = kThemeColor;
    nvc.navigationBar.tintColor = [UIColor whiteColor];//RGBHex(@"#00BDEE");
    [nvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UIBarButtonItem appearance] setTintColor:kThemeColor];
    
    nvc.navigationBar.barStyle = UIBarStyleBlack;
    
    MenuViewController* vc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    
    RESideMenu* sideMenu = [[RESideMenu alloc] initWithContentViewController:nvc leftMenuViewController:vc rightMenuViewController:nil];
    self.window.rootViewController = sideMenu;
    [self.window makeKeyAndVisible];
    
    [__serviceCenter setup];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [__serviceCenter stopAllServices];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
    [__serviceCenter startAllServices];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
