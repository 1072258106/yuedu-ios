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
    [self.downloadButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* aModel = [self article];

        [SRV(DownloadService) download:aModel preprocess:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (error.code) {
                    case DownloadErrorCodeAlreadyDownloading:
                        [SVProgressHUD showErrorWithStatus:@"已在队列中"];
                        break;
                    case DownloadErrorCodeAlreadyDownloaded:
                        [SVProgressHUD showErrorWithStatus:@"已下载"];
                        break;
                    default:
                        [SVProgressHUD showErrorWithStatus:@"已加入下载队列"];
                        break;
                }
            });
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.favorButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* aModel = [self article];
        aModel.isFavored = !aModel.isFavored;
        [self updateFavorButton];
        [SRV(DataService) writeData:aModel completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.shareButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* aModel = [self article];
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

- (YDSDKArticleModelEx* )article {
    if ([self.model isKindOfClass:[NSURLSessionTask class]]) {
        return [(NSURLSessionTask* )self.model articleModel];
    } else {
        return self.model;
    }
}

- (void)updateFavorButton {
    YDSDKArticleModelEx* aModel = [self article];
    [self.favorButton setTitle:aModel.isFavored?@"取消收藏":@"收藏"
                      forState:UIControlStateNormal];
    
    [self.favorButton setImage:aModel.isFavored?[UIImage imageNamed:@"icon_action_favored.png"]:[UIImage imageNamed:@"icon_action_favor.png"] forState:UIControlStateNormal];
}

@end
