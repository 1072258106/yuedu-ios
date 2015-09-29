//
//  HistoryViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

static int const kCountPerTime = 20;


@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"最近播放";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_delete.png"] action:^{
        UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:nil message:@"您确定清空已播放记录?"];
        [alert bk_addButtonWithTitle:@"清空" handler:^{
            [SRV(ArticleService) deleteAllPlayed:^{
                [self load];
                [self showWithSuccessedMessage:@"清空成功"];
            }];
        }];
        
        [alert bk_addButtonWithTitle:@"取消" handler:nil];
        [alert show];
    }];
        
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self load];
    }];
    
    [self load];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)load {
    [SRV(ArticleService) listPlayed:kCountPerTime completion:^(NSArray *array) {
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
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SRV(ArticleService) listPlayed:(int)[self.tableData count]+kCountPerTime completion:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData:array];
                [self.tableView.footer endRefreshing];
                
                if ([self.tableData count] == [array count]) {
                    self.tableView.footer = nil;
                }
            });
        }];
    }];
}

@end
