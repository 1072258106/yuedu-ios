//
//  FavorViewController.m
//  YueduFM
//
//  Created by StarNet on 9/26/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "FavorViewController.h"

@interface FavorViewController ()

@end

static int const kCountPerTime = 20;


@implementation FavorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的收藏";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_delete.png"] action:^{
            UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:nil message:@"您确定清空已所有收藏文章?"];
            [alert bk_addButtonWithTitle:@"清空" handler:^{
                [SRV(ArticleService) deleteAllFavored:^{
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
    [SRV(ArticleService) listFavored:kCountPerTime completion:^(NSArray *array) {
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
        [SRV(ArticleService) listFavored:(int)[self.tableData count]+kCountPerTime completion:^(NSArray *array) {
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
    return [UINib nibWithNibName:@"FavorActionTableViewCell" bundle:nil];
}

@end
