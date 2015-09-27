//
//  NSString+Extension.h
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (NSURL* )url;

+ (NSString* )stringWithSeconds:(int)seconds;

- (NSString *)sha1;

@end
