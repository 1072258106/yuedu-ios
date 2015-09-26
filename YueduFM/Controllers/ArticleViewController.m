//
//  ArticleViewController.m
//  YueduFM
//
//  Created by StarNet on 9/26/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleViewController.h"
#import "ArticleTableViewCell.h"

static NSString* const kCellIdentifier = @"kCellIdentifier";

@interface ArticleViewController ()

@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
