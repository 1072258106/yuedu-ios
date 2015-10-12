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
                                           @"config":^(UITableViewCell* cell){
                                               [SRV(SettingsService) bk_addObserverForKeyPath:@"autoCloseRestTime" task:^(id target) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       int seconds = SRV(SettingsService).autoCloseRestTime;
                                                       cell.detailTextLabel.text = seconds > 0?[NSString fullStringWithSeconds:seconds]:nil;
                                                   });
                                               }];
                                           },
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
                                                [[UIApplication sharedApplication] openURL:[weakSelf rateURL]];
                                           }
                                           },
                                       @{
                                           @"title":@"关于我们",
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(__weak UITableViewCell* cell){
                                               AboutViewController* vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
                                               [weakSelf.navigationController pushViewController:vc animated:YES];
                                           }
                                           },
                                       ]
                               };
    
    self.tableData = @[section1, section2];
}

- (NSURL* )rateURL {
    NSString* URLString;
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString* appId = @"1048612734";
    if (ver >= 7.0 && ver < 7.1) {
        URLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appId];
    } else if (ver >= 8.0) {
        URLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
    } else {
        URLString = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
    }
    return URLString.url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
