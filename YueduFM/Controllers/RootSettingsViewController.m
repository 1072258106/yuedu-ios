//
//  RootSettingsViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "RootSettingsViewController.h"
#import "AutoCloseSettingsViewController.h"
#import "AboutViewController.h"
#import "ClearSettingsViewController.h"

@interface RootSettingsViewController ()

@end

@implementation RootSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    SettingsService* service = SRV(SettingsService);
    __weak typeof(self) weakSelf = self;
    NSDictionary* section1 = @{@"header":@"流量",
                               @"footer":@"关闭提醒后，在非WiFi模式下收听和下载在线文章时，将不再显示流量提醒.",
                               @"rows":@[
                                       @{
                                           @"title":@"流量保护提醒",
                                           @"accessoryView":[UISwitch switchWithOn:service.flowProtection action:^(BOOL isOn) {
                                               service.flowProtection = isOn;
                                           }],
                                           },
                                       ]
                               };
    NSDictionary* section2 = @{@"header":@"应用",
                               @"rows":@[
                                       @{
                                           @"title":@"定时关闭",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               AutoCloseSettingsViewController* vc = [[AutoCloseSettingsViewController alloc] initWithNibName:@"AutoCloseSettingsViewController" bundle:nil];
                                               [weakSelf.navigationController pushViewController:vc animated:YES];
                                           }
                                           },
                                       @{
                                           @"title":@"清空占用空间",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               ClearSettingsViewController* vc = [[ClearSettingsViewController alloc] initWithNibName:@"ClearSettingsViewController" bundle:nil];
                                               [weakSelf.navigationController pushViewController:vc animated:YES];
                                           }
                                           },
                                       @{
                                           @"title":@"鼓励一下",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               NSString* URLString = [NSString stringWithFormat:
                                                                @"https://itunes.apple.com/cn/app/wei-ju/id1000339694?l=en&mt=8"];
                                               [[UIApplication sharedApplication] openURL:URLString.url];
                                           }
                                           },
                                       @{
                                           @"title":@"关于我们",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               AboutViewController* vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
                                               [weakSelf.navigationController pushViewController:vc animated:YES];
                                           }
                                           },
                                       ]
                               };
    
    self.tableData = @[section1, section2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
