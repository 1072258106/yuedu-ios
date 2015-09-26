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
#import "ActionTableViewCell.h"

@interface MainViewController () {
    PlayerBar*      _playerBar;
    REMenu*         _menu;
    NSInteger       _selectIndex;
    NSIndexPath*    _openedIndexPath;
}

@end

static NSString* const kCellIdentifier = @"kCellIdentifier";
static NSString* const kActionCellIdentifier = @"kActionCellIdentifier";
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

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_menu.png"] action:^{
        [self presentLeftMenuViewController:nil];
    }];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"icon_nav_search.png"] action:^{
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    [PlayerBar setContainer:self.view];
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
        [SRV(ArticleService) list:(int)[self.tableData count]+kCountPerTime channel:[self currentChannel] completion:^(NSArray *array) {
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

- (void)loadCurrentChannelData {
    [SRV(ArticleService) list:kCountPerTime channel:[self currentChannel] completion:^(NSArray *array) {
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData:array];
            [self.tableView.header endRefreshing];
            [self showWithSuccessedMessage:@"更新完成"];
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

- (void)reloadMenu {
    NSMutableArray* array = [NSMutableArray array];
    [SRV(ChannelService).channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YDSDKChannelModel* channel = obj;
        REMenuItem* item = [[REMenuItem alloc] initWithTitle:channel.name image:nil highlightedImage:nil action:^(REMenuItem *item) {
            UIButton* button = (UIButton*)self.navigationItem.titleView;
            [button setTitle:item.title forState:UIControlStateNormal];
            _selectIndex = [_menu.items indexOfObject:item];
            [self.tableView.header beginRefreshing];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableViewControllerProtocol
- (UINib* )nibForExpandCell {
    return [UINib nibWithNibName:@"ActionTableViewCell" bundle:nil];
}

- (CGFloat)heightForExpandCell {
    return 60;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDSDKArticleModel* model = self.tableData[indexPath.row];
    ArticleTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    
    [cell.moreButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    [cell.moreButton bk_addEventHandler:^(id sender) {
        
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

@end
