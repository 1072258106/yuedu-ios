//
//  PlayerService.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "PlayerService.h"

@implementation ServiceCenter (PlayerService)

CATEGORY_PROPERTY_GET_SET(DOUAudioStreamer*, audioStreamer, setAudioStreamer:);

- (void)setPlayingView:(ArticleTableViewCell* )cell {
    static ArticleTableViewCell* _cell;
    
    if (_cell) {
        _cell.playing = NO;
    }
    
    _cell = cell;
    _cell.playing = YES;
}

- (void)playerPlay:(NSURL* )url statusChanged:(void(^)(DOUAudioStreamerStatus status))statusChanged {
    self.audioStreamer = [[DOUAudioStreamer alloc] initWithAudioFile:url];
    
    [self.audioStreamer bk_removeAllBlockObservers];
    [self.audioStreamer bk_addObserverForKeyPath:@"status" task:^(id target) {
        if (statusChanged) {
            statusChanged(self.audioStreamer.status);
        }
    }];
    
    [self.audioStreamer play];
}

- (void)playerStop {
    [self.audioStreamer stop];
}

@end

@implementation PlayerService

@end
