//
//  NSString+Extension.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSURL* )url {
    return [NSURL URLWithString:self];
}

+ (NSString* )stringWithSeconds:(int)seconds {
    if (seconds < 0) seconds = 0;
    
    int s = (int)seconds%60;
    int min = seconds/60;
    int m = min%60;
    int h = min/60;
    
    NSString* str = nil;
    if (h) {
        str = [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
    } else {
        str = [NSString stringWithFormat:@"%d:%02d", m, s];
    }
    return str;
}

@end
