//
//  ChannelService.h
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"

@interface ServiceCenter (ChannelService)

@property (nonatomic, strong) NSArray* channelArray;

- (void)channelCheckout:(void(^)(NSError* error))completion;
- (void)channelFetch:(void(^)(NSError* error))completion;
@end

@interface ChannelService : BaseService

@end
