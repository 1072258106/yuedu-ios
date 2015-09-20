//
//  PlayerService.h
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "BaseService.h"
#import "ArticleTableViewCell.h"

@interface ServiceCenter (PlayerService)

@property (nonatomic, strong) DOUAudioStreamer* audioStreamer;

- (void)setPlayingView:(ArticleTableViewCell* )cell;

- (void)playerPlay:(NSURL* )url statusChanged:(void(^)(DOUAudioStreamerStatus status))statusChanged;
- (void)playerStop;

@end

@interface PlayerService : BaseService



@end
