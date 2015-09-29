//
//  WebViewController.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, copy) void(^viewDidDisappearBlock)();

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

+ (instancetype)controllerWithURL:(NSURL* )url didDisappear:(void(^)())disappear {
    WebViewController* wvc = [[WebViewController alloc] initWithURL:url];
    wvc.supportedWebNavigationTools = DZNWebNavigationToolAll;
    wvc.supportedWebActions = DZNWebActionAll;
    wvc.showLoadingProgress = YES;
    wvc.allowHistory = YES;
    wvc.hideBarsWithGestures = YES;
    wvc.viewDidDisappearBlock = disappear;
    return wvc;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.viewDidDisappearBlock) {
        self.viewDidDisappearBlock();
    }
}

@end
