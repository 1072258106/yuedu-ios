//
//  SearchViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () <UISearchBarDelegate> {
    UISearchBar* _searchBar;

}

@end

static int const kCountPerTime = 10;

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 245, 25)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.tintColor = RGBHex(@"#A0A0A0");
    _searchBar.placeholder = @"标题、作者、播音员";
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 40, 25);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button bk_addEventHandler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_searchBar], [[UIBarButtonItem alloc] initWithCustomView:button]];
    [_searchBar becomeFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self searchDidFinished];
}

- (void)searchDidFinished {
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
        [self addFooter];
    }
}

- (void)addFooter {
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SRV(ArticleService) list:(int)[self.tableData count]+kCountPerTime filter:_searchBar.text completion:^(NSArray *array) {
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

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [SRV(ArticleService) list:20 filter:searchText completion:^(NSArray *array) {
        [self reloadData:array];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchDidFinished];
}

@end
