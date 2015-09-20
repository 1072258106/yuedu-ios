//
//  PlayerBar.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "PlayerBar.h"

@interface PlayerBar () {
    NSTimer*    _timer;
    UIView*     _processBar;
}

@end

@implementation PlayerBar

- (void)awakeFromNib {
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = RGBHex(@"#D0D0D0");
    [self addSubview:line];
    
    _processBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    _processBar.backgroundColor = kThemeColor;
    [self addSubview:_processBar];
    
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        if (__serviceCenter.audioStreamer.duration) {
            _processBar.width = (self.width*__serviceCenter.audioStreamer.currentTime)/__serviceCenter.audioStreamer.duration;
            
        }
    } repeats:YES];
    
    [self.imageView setImage:[UIImage imageWithColor:kThemeColor]];
    [__serviceCenter bk_addObserverForKeyPath:@"currentArticleModel" task:^(id target) {
        YDSDKArticleModel* model = __serviceCenter.currentArticleModel;
        [self.imageView sd_setImageWithURL:model.pictureURL.url];
        self.titleLabel.text = model.title;
        self.authorLabel.text = model.author;
        self.speakerLabel.text = model.speaker;
        self.durationLabel.text = [NSString stringWithSeconds:model.duration];
        
        if (__serviceCenter.audioStreamer.status == DOUAudioStreamerBuffering
            || __serviceCenter.audioStreamer.status == DOUAudioStreamerPlaying) {
            self.playing = [model.audioURL isEqualToString:__serviceCenter.audioStreamer.url.absoluteString];
        } else {
            self.playing = NO;
        }
        
        [__serviceCenter.audioStreamer bk_addObserverForKeyPath:@"status" task:^(id target) {
            
        }];
        
        [self.playButton bk_addEventHandler:^(id sender) {
            if (self.playing) {
                [__serviceCenter articlePause];
            } else {
                [__serviceCenter articlePlay:model statusChanged:^(DOUAudioStreamerStatus status) {
                    
                }];
            }
            self.playing = !self.playing;
        } forControlEvents:UIControlEventTouchUpInside];
    }];
    
    
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    self.playButton.selected = playing;
}

@end
