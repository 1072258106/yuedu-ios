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

    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [SRV(ArticleService) listFavored:kCountPerTime completion:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData:array];
                [self.tableView.header endRefreshing];
            });
        }];
    }];
    
    [self.tableView.header beginRefreshing];
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

@end
