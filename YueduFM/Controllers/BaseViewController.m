//
//  BaseViewController.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    UILabel* label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
