//
//  MainViewController.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "MainViewController.h"
#import "ArticleTableViewCell.h"

@interface MainViewController () {
    NSArray* _tableData;
}

@end

static NSString* const kCellIdentifier = @"kCellIdentifier";

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"悦读FM";

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"nav_icon_menu.png"] action:^{
        [self presentLeftMenuViewController:nil];
    }];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"nav_icon_search.png"] action:^{
        NSLog(@"11111");
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    
    [__serviceCenter articleFetchLatest:^(NSArray *array, NSError *error) {
        [self reloadData:array];
    }];
}

- (void)reloadData:(NSArray*)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        _tableData = [NSArray arrayWithArray:data];
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.tableView = tableView;
    
    YDSDKArticleModel* model = _tableData[indexPath.row];
    
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YDSDKArticleModel* model = _tableData[indexPath.row];
    
    DZNWebViewController* wvc = [[DZNWebViewController alloc] initWithURL:model.url.url];
    wvc.supportedWebNavigationTools = DZNWebNavigationToolAll;
    wvc.supportedWebActions = DZNWebActionAll;
    wvc.showLoadingProgress = YES;
    wvc.allowHistory = YES;
    wvc.hideBarsWithGestures = YES;

    [self.navigationController pushViewController:wvc animated:YES];
}

@end
