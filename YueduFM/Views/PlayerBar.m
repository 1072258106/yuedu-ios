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

@property (nonatomic, assign) CGFloat progress;

@end

@implementation PlayerBar

- (void)awakeFromNib {
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = RGBHex(@"#D0D0D0");
    [self addSubview:line];
    
    _processBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    _processBar.backgroundColor = kThemeColor;
    self.progress = 0;
    [self addSubview:_processBar];
#if 0
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        if (self.serviceCenter.audioStreamer.duration) {
            _processBar.width = (self.width*self.serviceCenter.audioStreamer.currentTime)/self.serviceCenter.audioStreamer.duration;
            
        }
    } repeats:YES];
    
    [self.imageView setImage:[UIImage imageWithColor:kThemeColor]];
    [self.serviceCenter bk_addObserverForKeyPath:@"currentArticleModel" task:^(id target) {
        YDSDKArticleModel* model = self.serviceCenter.currentArticleModel;
        [self.imageView sd_setImageWithURL:model.pictureURL.url];
        self.titleLabel.text = model.title;
        self.authorLabel.text = model.author;
        self.speakerLabel.text = model.speaker;
        self.durationLabel.text = [NSString stringWithSeconds:model.duration];
        
        if (self.serviceCenter.audioStreamer.status == DOUAudioStreamerBuffering
            || self.serviceCenter.audioStreamer.status == DOUAudioStreamerPlaying) {
            self.playing = [model.audioURL isEqualToString:self.serviceCenter.audioStreamer.url.absoluteString];
        } else {
            self.playing = NO;
        }
        
        [self.serviceCenter.audioStreamer bk_addObserverForKeyPath:@"status" task:^(id target) {
            
        }];
        
        [self.playButton bk_addEventHandler:^(id sender) {
            if (self.playing) {
                [self.serviceCenter articlePause];
            } else {
                [self.serviceCenter articlePlay:model statusChanged:^(DOUAudioStreamerStatus status) {
                    
                }];
            }
            self.playing = !self.playing;
        } forControlEvents:UIControlEventTouchUpInside];
    }];
    
    
    UILongPressGestureRecognizer* gesture = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        static CGPoint point;
        
        switch (state) {
            case UIGestureRecognizerStateBegan:
                point = location;
                break;
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStateEnded: {
                CGFloat x = location.x - point.x;
                self.progress += x/self.width;
                break;
            }
            default:
                break;
        }
        if (state == UIGestureRecognizerStateEnded) {
            AudioStreamer* streamer = self.serviceCenter.steamer;
//            streamer.progress = self.progress;
            [streamer seekToTime:streamer.duration*self.progress];
//            DOUAudioStreamer* streamer = self.serviceCenter.audioStreamer;
//            streamer.currentTime = streamer.duration*self.progress;
        }
        point = location;
    }];

    gesture.numberOfTouchesRequired = 1;
    gesture.minimumPressDuration = 0.1;
    gesture.allowableMovement = 200;
    [self addGestureRecognizer:gesture];
#endif
}

- (CGFloat)progress {
    return _processBar.width/self.width;
}

- (void)setProgress:(CGFloat)progress {
    progress = fmax(0, progress);
    progress = fmin(progress, 1);
    _processBar.width = self.width*progress;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    self.playButton.selected = playing;
}

@end
