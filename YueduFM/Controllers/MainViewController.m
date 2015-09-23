//
//  MainViewController.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "MainViewController.h"
#import "ArticleTableViewCell.h"
#import "PlayerBar.h"
#import "REMenu.h"

@interface MainViewController () {
    NSArray*    _tableData;
    PlayerBar*  _playerBar;
    REMenu*     _menu;
    NSInteger   _selectIndex;
}

@end

static NSString* const kCellIdentifier = @"kCellIdentifier";
static int const kCountPerTime = 20;

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* button = [UIButton viewWithNibName:@"TitleView"];
    button.backgroundColor = [UIColor clearColor];
    [button bk_addEventHandler:^(id sender) {
        if (_menu.isOpen)
            return [_menu close];
        
        [_menu showFromNavigationController:self.navigationController];        
    } forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"nav_icon_menu.png"] action:^{
        [self presentLeftMenuViewController:nil];
    }];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"nav_icon_search.png"] action:^{
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    
    [self setupPlayerBar];
    [self setupMenu];
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [SRV(ArticleService) fetchLatest:^(NSError *error) {
            [self loadCurrentChannelData];
        }];
    }];
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
}

- (void)addFooter {
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SRV(ArticleService) list:(int)[_tableData count]+kCountPerTime channel:[self currentChannel] completion:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData:array];
                [self.tableView.footer endRefreshing];
                
                if ([_tableData count] == [array count]) {
                    self.tableView.footer = nil;
                }
            });
        }];
    }];
}

- (void)loadCurrentChannelData {
    [SRV(ArticleService) list:kCountPerTime channel:[self currentChannel] completion:^(NSArray *array) {
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData:array];
            [self.tableView.header endRefreshing];
            [self addFooter];
        });
    }];
}

- (int)currentChannel {
    NSArray* array = [SRV(ChannelService) channels];
    if ([array count] <= _selectIndex) {
        return 1;
    } else {
        return ((YDSDKChannelModel* )array[_selectIndex]).aid;
    }
}

- (void)setupPlayerBar {
    _playerBar = [PlayerBar viewWithNibName:@"PlayerBar"];
    _playerBar.top = self.view.height-_playerBar.height;
    _playerBar.width = self.view.width;
    _playerBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [_playerBar.actionButton bk_addEventHandler:^(id sender) {
        //        [self.navigationController pushViewController:[WebViewController controllerWithURL:self.serviceCenter.currentArticleModel.url.url] animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [_playerBar.moreButton bk_addEventHandler:^(id sender) {
        UIActionSheet* sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [sheet bk_addButtonWithTitle:@"下载" handler:^{
            
        }];
        [sheet bk_addButtonWithTitle:@"收藏" handler:^{
            
        }];
        [sheet bk_addButtonWithTitle:@"分享" handler:^{
            
        }];
        
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [sheet showInView:_playerBar];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_playerBar];
}

- (void)reloadMenu {
    NSMutableArray* array = [NSMutableArray array];
    [SRV(ChannelService).channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YDSDKChannelModel* channel = obj;
        REMenuItem* item = [[REMenuItem alloc] initWithTitle:channel.name image:nil highlightedImage:nil action:^(REMenuItem *item) {
            UIButton* button = (UIButton*)self.navigationItem.titleView;
            [button setTitle:item.title forState:UIControlStateNormal];
            _selectIndex = [_menu.items indexOfObject:item];
            [self.tableView.header beginRefreshing];
            [self loadCurrentChannelData];
        }];
        [array addObject:item];
    }];
    
    _menu.items = array;
}

- (void)setupMenu {
    _menu = [[REMenu alloc] init];
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 3);
    _menu.shadowOpacity = 0.2f;
    _menu.shadowRadius = 10.0f;
    _menu.backgroundColor = [UIColor whiteColor];
    _menu.textColor = kThemeColor;
    _menu.textShadowColor = [UIColor clearColor];
    _menu.textOffset = CGSizeZero;
    _menu.textShadowOffset = CGSizeZero;
    _menu.highlightedTextColor = [UIColor whiteColor];
    _menu.highlightedTextShadowColor = [UIColor clearColor];
    _menu.highlightedBackgroundColor = RGBHex(@"E0E0E0");
    _menu.highlightedSeparatorColor = RGBHex(@"E0E0E0");
    _menu.font = [UIFont systemFontOfSize:14.0f];
    _menu.separatorColor = RGBHex(@"E0E0E0");
    _menu.separatorHeight = 0.5f;
    _menu.separatorOffset = CGSizeMake(15, 0);
    _menu.borderWidth = 0;
    _menu.itemHeight = 40.f;
    [_menu bk_addObserverForKeyPath:@"isOpen" task:^(id target) {
        UIButton* button = (UIButton*)self.navigationItem.titleView;
        
        if (_menu.isOpen) {
            [button setImage:[UIImage imageNamed:@"icon_up_arrow"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_up_arrow_h"] forState:UIControlStateHighlighted];
        } else {
            [button setImage:[UIImage imageNamed:@"icon_down_arrow"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_down_arrow_h"] forState:UIControlStateHighlighted];
        }
    }];

    [self reloadMenu];
    [SRV(ChannelService) bk_addObserverForKeyPath:@"channels" task:^(id target) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadMenu];
        });
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
    
    YDSDKArticleModel* model = _tableData[indexPath.row];
    cell.model = model;
    
    [cell.moreButton bk_addEventHandler:^(id sender) {
        UIActionSheet* sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [sheet bk_addButtonWithTitle:@"下载" handler:^{
            
        }];
        [sheet bk_addButtonWithTitle:@"收藏" handler:^{
            
        }];
        [sheet bk_addButtonWithTitle:@"分享" handler:^{
            
        }];
        
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [sheet showInView:_playerBar];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YDSDKArticleModel* model = _tableData[indexPath.row];
    WebViewController* vc = [WebViewController controllerWithURL:model.url.url];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
