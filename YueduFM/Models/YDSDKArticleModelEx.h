//
//  YDSDKArticleModelEx.h
//  YueduFM
//
//  Created by StarNet on 9/22/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import <YueduFMSDK/YueduFMSDK.h>

@interface YDSDKArticleModel (YDSDKArticleModelEx)

@end

@interface YDSDKArticleModelEx : YDSDKArticleModel

@property (nonatomic, assign) YDSDKModelState state;

@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL isRead;

@end
