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
    DOUAudioStreamer*   _streamer;
    UIImageView*        _imageView;
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
        _imageView = [[UIImageView alloc] init];
    }
    return self;
}


- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)start {
    self.isPlaying = self.isPlaying;
}

- (void)dealloc {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)play:(YDSDKArticleModelEx* )model {
    if (!model) return;
    
    if (![model.audioURL isEqualToString:self.playingModel.audioURL]) {
        self.playingModel = model;
        SRV(ArticleService).activeArticleModel = model;
        
        model.preplayDate = [NSDate dateWithTimeIntervalSince1970:0];
        model.playedDate = [NSDate date];
        [SRV(DataService) writeData:model completion:nil];
        
        [_streamer bk_removeAllBlockObservers];
        [_streamer stop];
        NSLog(@"play:%@", [SRV(DownloadService) playableURLForModel:self.playingModel]);
        _streamer = [DOUAudioStreamer streamerWithAudioFile:[[SRV(DownloadService) playableURLForModel:self.playingModel] audioFileURL]];
        [_streamer bk_addObserverForKeyPath:@"duration" task:^(id target) {
            NSMutableDictionary* info = self.nowPlayingInfo;
            if (!info[MPMediaItemPropertyPlaybackDuration]) {
                info[MPMediaItemPropertyPlaybackDuration] = @(_streamer.duration);
                self.nowPlayingInfo = info;
            }
        }];
        
        [_streamer bk_addObserverForKeyPath:@"status" task:^(id target) {
            if (_streamer.status == DOUAudioStreamerFinished) {
                self.isPlaying = NO;
                self.playingModel = nil;
                [self next];
            }
        }];
        
        NSDictionary* info = @{
                               MPMediaItemPropertyTitle:model.title,
                               MPMediaItemPropertyAlbumTitle:model.author,
                               MPMediaItemPropertyArtist:model.speaker,
                               MPNowPlayingInfoPropertyPlaybackRate:@(1),
                               };
        
        self.nowPlayingInfo = (NSMutableDictionary* )info;
        
        [_imageView sd_setImageWithURL:model.pictureURL.url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                NSMutableDictionary* info = self.nowPlayingInfo;
                info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:image];
                self.nowPlayingInfo = info;
            }
        }];
    }
    
    //在线资源需要验证网络连接情况
    if (![_streamer.url isFileURL]) {
        if (SRV(ReachabilityService).status == NotReachable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:SRV(ReachabilityService).statusString];
            });
            self.isPlaying = NO;
        } else if ((SRV(ReachabilityService).status == ReachableViaWWAN) && SRV(SettingsService).flowProtection) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:SRV(ReachabilityService).statusString];
            });
            [_streamer play];
            self.isPlaying = YES;
        } else {
            [_streamer play];
            self.isPlaying = YES;
        }
    } else {
        [_streamer play];
        self.isPlaying = YES;
    }
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
        if (nextModel) {
            [self play:nextModel];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"已是最后一篇文章"];
            });
        }
    }];
}

- (NSTimeInterval)duration {
    return self.playingModel?_streamer.duration:0;
}

- (NSTimeInterval)currentTime {
    return self.playingModel?_streamer.currentTime:0;
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
