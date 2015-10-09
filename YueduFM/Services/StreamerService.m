//
//  StreamerService.m
//  YueduFM
//
//  Created by StarNet on 9/28/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "StreamerService.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DOUAudioStreamer.h"

@interface StreamerService () {
    DOUAudioStreamer* _streamer;
}

@property (nonatomic, strong) NSMutableDictionary* nowPlayingInfo;

@end

@implementation StreamerService

- (instancetype)initWithServiceCenter:(ServiceCenter *)serviceCenter {
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory: AVAudioSessionCategoryPlayback error:nil];
        [session setActive: YES error:nil];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

- (void)dealloc {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)play:(YDSDKArticleModelEx* )model {
    if (!model) return;
    
    if (![model.audioURL isEqualToString:self.playingModel.audioURL]) {
        self.playingModel = model;
        SRV(ArticleService).activeArticleModel = model;
        
        [_streamer bk_removeAllBlockObservers];
        _streamer = [DOUAudioStreamer streamerWithAudioFile:[[model playableURL] audioFileURL]];
        [_streamer bk_addObserverForKeyPath:@"duration" task:^(id target) {
            NSLog(@"=========stream==========:%f", _streamer.duration);

//            if (_streamer.status == DOUAudioStreamerPlaying) {
                NSMutableDictionary* info = self.nowPlayingInfo;
                if (!info[MPMediaItemPropertyPlaybackDuration]) {
                    info[MPMediaItemPropertyPlaybackDuration] = @(_streamer.duration);
                    self.nowPlayingInfo = info;
                }
//            }
        }];
    }
    
    [_streamer play];
    
    NSDictionary* info = @{
                           MPMediaItemPropertyTitle:model.title,
                           MPMediaItemPropertyArtist:[NSString stringWithFormat:@"作者:%@ 播音员:%@", model.author, model.speaker],
                           MPNowPlayingInfoPropertyPlaybackRate:@(1),
                           };
    
    self.nowPlayingInfo = (NSMutableDictionary* )info;
    
    UIImageView* imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:model.pictureURL.url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSMutableDictionary* info = self.nowPlayingInfo;
            info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:image];
            self.nowPlayingInfo = info;
        }
    }];
    
    self.isPlaying = YES;
}

- (void)setNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

- (NSMutableDictionary* )nowPlayingInfo {
    return [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
}

- (void)pause {
    [_streamer pause];
    self.isPlaying = NO;
}

- (void)resume {
    [self play:self.playingModel];
}

- (void)next {
    [SRV(ArticleService) nextPreplay:self.playingModel completion:^(YDSDKArticleModelEx *nextModel) {
        [self play:nextModel];
    }];
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

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self resume];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
        default:
            break;
    }
}

@end
