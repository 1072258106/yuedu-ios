//
//  ClearSettingsViewController.m
//  YueduFM
//
//  Created by StarNet on 10/12/15.
//  Copyright © 2015 StarNet. All rights reserved.
//

#import "ClearSettingsViewController.h"

@interface ClearSettingsViewController ()

@end

@implementation ClearSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"清空占用空间";
    
    NSDictionary* section1 = @{
                               @"footer":@"清空所有已经缓存的图片.",
                               @"rows":@[
                                       @{
                                           @"title":@"清空图片",
                                           @"detail":[NSString stringWithFileSize:[[SDImageCache sharedImageCache] getSize]],
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           cell.detailTextLabel.text = [NSString stringWithFileSize:[[SDImageCache sharedImageCache] getSize]];
                                                           [SVProgressHUD showSuccessWithStatus:@"清空成功"];
                                                       });
                                                   }];
                                               });
                                           }
                                           },
                                       ]
                               };
    NSDictionary* section2 = @{
                               @"footer":@"清空所有已经下载的声音文件.",
                               @"rows":@[
                                       @{
                                           @"title":@"清空已下载文章",
                                           @"detail":[NSString stringWithFileSize:[SRV(DownloadService) cacheSize]],
                                           @"accessoryType":@(UITableViewCellAccessoryDisclosureIndicator),
                                           @"action":^(UITableViewCell* cell){
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   [SRV(ArticleService) deleteAllDownloaded:^{
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           cell.detailTextLabel.text = [NSString stringWithFileSize:[SRV(DownloadService) cacheSize]];
                                                           [SVProgressHUD showSuccessWithStatus:@"清空成功"];
                                                       });                                                       
                                                   }];
                                               });
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
