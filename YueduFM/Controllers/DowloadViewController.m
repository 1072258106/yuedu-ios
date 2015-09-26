//
//  DowloadViewController.m
//  YueduFM
//
//  Created by StarNet on 9/26/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "DowloadViewController.h"

@interface DowloadViewController ()

@end

@implementation DowloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"已下载", @"正在下载"]];
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
