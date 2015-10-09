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
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_delete.png"] action:^{
        UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:nil message:@"您确定清空已所有项目?"];
        [alert bk_addButtonWithTitle:@"清空" handler:^{
            [SRV(ArticleService) deleteAllPreplay:^{
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
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SRV(ArticleService) listPreplay:(int)[self.tableData count]+kCountPerTime completion:^(NSArray *array) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UINib* )nibForExpandCell {
    return [UINib nibWithNibName:@"PlayListActionTableViewCell" bundle:nil];
}

@end
