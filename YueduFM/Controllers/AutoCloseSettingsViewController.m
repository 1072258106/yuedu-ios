//
//  AutoCloseSettingsViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "AutoCloseSettingsViewController.h"

@interface AutoCloseSettingsViewController ()

@end

@implementation AutoCloseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自动关闭";
    
    NSDictionary* section1 = @{@"header":@"时间",
                               @"rows":@[
                                       @{
                                           @"row":@"无",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       @{
                                           @"row":@"10分钟",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       @{
                                           @"row":@"20分钟",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       @{
                                           @"row":@"30分钟",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       @{
                                           @"row":@"1小时",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       @{
                                           @"row":@"2小时",
                                           @"accessoryType":@(UITableViewCellAccessoryCheckmark)
                                           },
                                       ]
                               };
    
    self.tableData = @[section1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
