//
//  AutoCloseSettingsViewController.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "AutoCloseSettingsViewController.h"

@interface AutoCloseSettingsViewController ()

@end

@implementation AutoCloseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自动关闭";
    
    __weak typeof(self) weakSelf = self;
    void(^action)(UITableViewCell* cell) = ^(UITableViewCell* cell) {
        [[weakSelf.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(UITableViewCell* )obj setAccessoryView:nil];
        }];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cell_check.png"]];
        SRV(SettingsService).autoCloseLevel = [weakSelf.tableView indexPathForCell:cell].row;
    };
    
    NSMutableArray* rows = [NSMutableArray array];
    NSInteger level = SRV(SettingsService).autoCloseLevel;
    [SRV(SettingsService).autoCloseTimes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary* row = [NSMutableDictionary dictionary];
        row[@"row"] = [self formatTime:[obj intValue]];
        row[@"action"] = action;
        if (idx == level) {
            row[@"accessoryView"] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cell_check.png"]];
        }
        [rows addObject:row];
    }];
    
    
    NSDictionary* section1 = @{@"header":@"时间",
                               @"rows":rows
                               };
    
    self.tableData = @[section1];
}

- (NSString* )formatTime:(int)minius {
    int h = minius/60;
    int m = minius%60;
    
    NSMutableString* timeString = [NSMutableString string];
    if (!h && !m) {
        [timeString appendString:@"无"];
    } else {
        if (h) {
            [timeString appendFormat:@"%d小时", h];
        }
        
        if (m) {
            [timeString appendFormat:@"%d分钟", m];
        }
    }
    return timeString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
