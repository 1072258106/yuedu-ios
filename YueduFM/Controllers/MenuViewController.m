//
//  MenuViewController.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "MenuViewController.h"
#import "FavorViewController.h"
#import "DowloadViewController.h"
#import "RootSettingsViewController.h"
#import "HistoryViewController.h"

@interface MenuViewController () {
    NSArray*   _tableData;
}

@end

static NSString* const kCellIdentifier = @"kCellIdentifier";

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableData = @[
                   @{
                       @"image":@"icon_menu_download.png",
                       @"title":@"我的下载",
                       @"action":^{
                           DowloadViewController* vc = [[DowloadViewController alloc] initWithNibName:@"DowloadViewController" bundle:nil];
                           [self pushViewController:vc];
                       }
                       },
                   @{
                       @"image":@"icon_menu_favor.png",
                       @"title":@"我的收藏",
                       @"action":^{
                           FavorViewController* vc = [[FavorViewController alloc] initWithNibName:@"FavorViewController" bundle:nil];
                           [self pushViewController:vc];
                       }
                       },
                   @{
                       @"image":@"icon_menu_history.png",
                       @"title":@"最近播放",
                       @"action":^{
                           HistoryViewController* vc = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
                           [self pushViewController:vc];
                       }
                       },
                   @{
                       @"image":@"icon_menu_settings.png",
                       @"title":@"设置",
                       @"action":^{
                           RootSettingsViewController* vc = [[RootSettingsViewController alloc] initWithNibName:@"RootSettingsViewController" bundle:nil];
                           [self pushViewController:vc];
                       }
                       },
                   ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
}

- (void)pushViewController:(UIViewController* )viewController {
    [(UINavigationController* )self.sideMenuViewController.contentViewController pushViewController:viewController animated:NO];
    [self.sideMenuViewController hideMenuViewController];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_menu_accessory.png"]];
    
    UIView* selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    selectedBackgroundView.backgroundColor = RGBA(0, 0, 0, 0.2);
    cell.selectedBackgroundView = selectedBackgroundView;

    
    NSDictionary* item = _tableData[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:item[@"image"]];
    cell.textLabel.text = item[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* item = _tableData[indexPath.row];
    if (item[@"action"]) {
        ((void(^)())item[@"action"])();
    }
}

@end
