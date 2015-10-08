//
//  YDSDKArticleModelEx.m
//  YueduFM
//
//  Created by StarNet on 9/22/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "YDSDKArticleModelEx.h"

@implementation YDSDKArticleModel (YDSDKArticleModelEx)
PPSqliteORMAsignRegisterName(@"article")

@end

@implementation YDSDKArticleModelEx

- (NSURL* )playableURL {
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:self.downloadURLString];
    return exist?self.downloadURLString.fileURL:self.audioURL.url;
}

@end
