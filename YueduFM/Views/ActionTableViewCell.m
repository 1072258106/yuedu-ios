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
        [self onDownloadButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.shareButton bk_addEventHandler:^(id sender) {
        [self onShareButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.favorButton bk_addEventHandler:^(id sender) {
        [self onFavorButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.deleteButton bk_addEventHandler:^(id sender) {
        [self onDeleteButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];

    [self.detailButton bk_addEventHandler:^(id sender) {
        [self onDetailButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];

    [self.addButton bk_addEventHandler:^(id sender) {
        [self onAddButtonPressed:nil];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(id)model {
    [super setModel:model];

    [[self article] bk_removeAllBlockObservers];
    [[self article] bk_addObserverForKeyPath:@"isFavored" task:^(id target) {
        [self updateFavorButton];
    }];
    
    [SRV(ArticleService) update:[self article] completion:nil];
}

- (YDSDKArticleModelEx* )article {
    if ([self.model isKindOfClass:[NSURLSessionTask class]]) {
        return [(NSURLSessionTask* )self.model articleModel];
    } else {
        return self.model;
    }
}

- (IBAction)onDownloadButtonPressed:(id)sender {
    YDSDKArticleModelEx* aModel = [self article];
    
    void(^preprocess)(NSError* error) = ^(NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (error.code) {
                case DownloadErrorCodeAlreadyDownloading:
                    [MessageKit showWithFailedMessage:@"该文章已在下载队列中"];
                    break;
                case DownloadErrorCodeAlreadyDownloaded:
                    [MessageKit showWithSuccessedMessage:@"该文章已下载"];
                    break;
                default:
                    [MessageKit showWithSuccessedMessage:@"该文章已加入下载队列中"];
                    break;
            }
        });
    };
    
    if ([SRV(SettingsService) flowProtection] && SRV(ReachabilityService).status == ReachableViaWWAN) {
        UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"网络连接提醒" message:@"当前网络处于非WiFi模式下，继续下载会被运营商收取流量费用"];
        [alert bk_addButtonWithTitle:@"继续" handler:^{
            [SRV(DownloadService) download:aModel protect:NO preprocess:preprocess];
        }];
        
        [alert bk_addButtonWithTitle:@"在WiFi时下载" handler:^{
            [SRV(DownloadService) download:aModel protect:YES preprocess:preprocess];
        }];
        
        [alert bk_setCancelButtonWithTitle:@"取消" handler:nil];
        
        [alert show];
    } else {
        [SRV(DownloadService) download:aModel protect:NO preprocess:preprocess];
    }
}

- (IBAction)onFavorButtonPressed:(id)sender {
    YDSDKArticleModelEx* aModel = [self article];
    aModel.isFavored = !aModel.isFavored;
    [SRV(DataService) writeData:aModel completion:nil];
}

- (IBAction)onShareButtonPressed:(id)sender {
    YDSDKArticleModelEx* aModel = [self article];
    [UIViewController showActivityWithURL:aModel.url.url completion:nil];
}

- (IBAction)onDeleteButtonPressed:(id)sender {
    
}

- (IBAction)onDetailButtonPressed:(id)sender {
    [[PlayerBar shareBar] setForceHidden:YES];
    [[UIViewController topViewController].navigationController pushViewController:[WebViewController controllerWithURL:[self article].url.url didDisappear:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PlayerBar shareBar] setForceHidden:NO];
        });
    }] animated:YES];
}

- (IBAction)onAddButtonPressed:(id)sender {
    
}

- (void)updateFavorButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        YDSDKArticleModelEx* aModel = [self article];
        [self.favorButton setTitle:aModel.isFavored?@"取消收藏":@"收藏"
                          forState:UIControlStateNormal];
        
        [self.favorButton setImage:aModel.isFavored?[UIImage imageNamed:@"icon_action_favored.png"]:[UIImage imageNamed:@"icon_action_favor.png"] forState:UIControlStateNormal];
    });
}

@end
