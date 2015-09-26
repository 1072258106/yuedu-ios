//
//  ActionTableViewCell.m
//  YueduFM
//
//  Created by StarNet on 9/24/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ActionTableViewCell.h"
#import "YDSDKArticleModelEx.h"

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [self.favorButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* aModel = self.model;
        aModel.isFavor = !aModel.isFavor;
        [self updateFavorButton];
        [SRV(DataService) writeData:aModel completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.shareButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* aModel = self.model;
        [UIViewController showActivityWithURL:aModel.url.url completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(id)model {
    [super setModel:model];
    [self updateFavorButton];
}

- (void)updateFavorButton {
    YDSDKArticleModelEx* aModel = self.model;
    [self.favorButton setTitle:aModel.isFavor?@"取消收藏":@"收藏"
                      forState:UIControlStateNormal];
    
    [self.favorButton setImage:aModel.isFavor?[UIImage imageNamed:@"icon_action_favored.png"]:[UIImage imageNamed:@"icon_action_favor.png"] forState:UIControlStateNormal];
}

@end
