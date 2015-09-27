//
//  DownloadActionTableViewCell.m
//  YueduFM
//
//  Created by StarNet on 9/27/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "DownloadActionTableViewCell.h"

@implementation DownloadActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.deleteButton bk_addEventHandler:^(id sender) {
        [SRV(DownloadService) deleteTask:self.model];
    } forControlEvents:UIControlEventTouchUpInside];
}

@end
