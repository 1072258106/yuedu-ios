//
//  StreamerService.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "StreamerService.h"
#import <AVFoundation/AVFoundation.h>
#import "DOUAudioStreamer.h"

@interface StreamerService () {
    DOUAudioStreamer* _streamer;
}

@end

@implementation StreamerService

- (instancetype)initWithServiceCenter:(ServiceCenter *)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory: AVAudioSessionCategoryPlayback error:nil];
        [session setActive: YES error:nil];
    }
    return self;
}

- (void)play:(YDSDKArticleModelEx* )model {
    if (![model.audioURL isEqualToString:self.playingModel.audioURL]) {
        self.playingModel = model;
        SRV(ArticleService).activeArticleModel = model;
        _streamer = [[DOUAudioStreamer alloc] initWithAudioFile:[[model playableURL] audioFileURL]];
    }
    
    [_streamer play];
    self.isPlaying = YES;
}

- (void)pause {
    [_streamer pause];
    self.isPlaying = NO;
}

- (NSTimeInterval)duration {
    return _streamer.duration;
}

- (NSTimeInterval)currentTime {
    return _streamer.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _streamer.currentTime = currentTime;
}

@end
