//
//  RootSettingsViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "RootSettingsViewController.h"
#import "AutoCloseSettingsViewController.h"

@interface RootSettingsViewController ()

@end

@implementation RootSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    NSDictionary* section1 = @{@"header":@"流量",
                               @"footer":@"关闭提醒后，在非WiFi模式下收听和下载在线文章时，将不再显示流量提醒.",
                               @"rows":@[
                                       @{
                                           @"row":@"流量保护提醒",
                                           @"accessoryView":[[UISwitch alloc] init],
                                           },
                                       ]
                               };
    NSDictionary* section2 = @{@"header":@"应用",
                               @"rows":@[
                                       @{
                                           @"row":@"定时关闭",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^{
                                               AutoCloseSettingsViewController* vc = [[AutoCloseSettingsViewController alloc] initWithNibName:@"AutoCloseSettingsViewController" bundle:nil];
                                               [self.navigationController pushViewController:vc animated:YES];
                                           }
                                           },
                                       @{
                                           @"row":@"清空占用空间",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator)
                                           },
                                       @{
                                           @"row":@"给我们评分",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator)
                                           },
                                       @{
                                           @"row":@"关于我们",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator)
                                           },
                                       ]
                               };
    
    self.tableData = @[section1, section2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
