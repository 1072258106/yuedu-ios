//
//  PlayListViewController.m
//  YueduFM
//
//  Created by StarNet on 9/29/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "PlayListViewController.h"

static int const kCountPerTime = 20;

@interface PlayListViewController ()

@end

@implementation PlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"播放队列";
    self.emptyString = @"所有将要播放的文章都在此.";
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_delete.png"] action:^{
        UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:nil message:@"您确定清空已所有项目?"];
        [alert bk_addButtonWithTitle:@"清空" handler:^{
            [SRV(ArticleService) deleteAllPreplay:^{
                [weakSelf load];
                [weakSelf showWithSuccessedMessage:@"清空成功"];
            }];
        }];
        
        [alert bk_addButtonWithTitle:@"取消" handler:nil];
        [alert show];
    }];
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf load];
    }];
    
    [self load];
}

- (void)load {
    [SRV(ArticleService) listPreplay:kCountPerTime completion:^(NSArray *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData:array];
            [self.tableView.header endRefreshing];
            if ([array count] >= kCountPerTime) {
                [self addFooter];
            }
        });
    }];
}

- (void)addFooter {
    __weak typeof(self) weakSelf = self;
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SRV(ArticleService) listPreplay:(int)[weakSelf.tableData count]+kCountPerTime completion:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadData:array];
                [weakSelf.tableView.footer endRefreshing];
                
                if ([weakSelf.tableData count] == [array count]) {
                    weakSelf.tableView.footer = nil;
                }
            });
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UINib* )nibForExpandCell {
    return [UINib nibWithNibName:@"PlayListActionTableViewCell" bundle:nil];
}

@end
