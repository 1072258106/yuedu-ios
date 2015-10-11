//
//  BaseViewController.m
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) CGFloat scrollY;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    UILabel* label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.dragging = NO;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.dragging = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat diffY = self.scrollY - scrollView.contentOffset.y;
    self.scrollY = scrollView.contentOffset.y;
    
    if (!self.dragging || (scrollView.contentOffset.y < -70)) return;
    
    if (diffY > 0) { //上滑
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerBarDidShowNotification object:nil];
    } else if (diffY < 0) { //下滑
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerBarDidHideNotification object:nil];
    }
    
}

- (void)dealloc {
    NSLog(@"DEALLOC====>%@", self);
}

@end
