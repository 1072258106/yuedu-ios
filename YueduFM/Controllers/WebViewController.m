//
//  WebViewController.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)controllerWithURL:(NSURL* )url {
    WebViewController* wvc = [[WebViewController alloc] initWithURL:url];
    wvc.supportedWebNavigationTools = DZNWebNavigationToolAll;
    wvc.supportedWebActions = DZNWebActionAll;
    wvc.showLoadingProgress = YES;
    wvc.allowHistory = YES;
    wvc.hideBarsWithGestures = YES;
    return wvc;
}

@end
