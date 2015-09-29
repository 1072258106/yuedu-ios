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


@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIView* container;

@end

@implementation PlayerBar

+ (instancetype)shareBar {
    static PlayerBar* bar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bar = [PlayerBar viewWithNibName:@"PlayerBar"];
    });
    return bar;
}

+ (void)setContainer:(UIView* )container {
    PlayerBar* bar = [PlayerBar shareBar];
    bar.container = container;
    [bar showIfNeed];
}

- (void)setForceHidden:(BOOL)forceHidden {
    _forceHidden = forceHidden;
    
    if (forceHidden) {
        [UIView animateWithDuration:0.3f animations:^{
            self.top = self.container.height;
        }];
    } else {
        self.top = self.container.height;
        [UIView animateWithDuration:0.3f animations:^{
            self.top -= self.height;
        }];
    }
}

- (void)showIfNeed {
    if (!_forceHidden && !self.visible && SRV(ArticleService).activeArticleModel && self.container) {
        self.width = self.container.width;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [self removeFromSuperview];
        [self.container addSubview:self];
        self.top = self.container.height;
        [UIView animateWithDuration:0.3f animations:^{
            self.top -= self.height;
        }];
        self.visible = YES;
    }
}

- (void)awakeFromNib {
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = RGBHex(@"#E0E0E0");
    [self addSubview:line];
    
    _processBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    _processBar.backgroundColor = kThemeColor;
    self.progress = 0;
    [self addSubview:_processBar];
    
    [self.imageView setImage:[UIImage imageWithColor:kThemeColor]];
    [SRV(ArticleService) bk_addObserverForKeyPath:@"activeArticleModel" task:^(id target) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showIfNeed];
            
            YDSDKArticleModel* model = [SRV(ArticleService) activeArticleModel];
            [self.imageView sd_setImageWithURL:model.pictureURL.url];
            self.titleLabel.text = model.title;
            self.authorLabel.text = model.author;
            self.speakerLabel.text = model.speaker;
            self.durationLabel.text = [NSString stringWithSeconds:model.duration];
            
            [self.playButton bk_addEventHandler:^(id sender) {
            } forControlEvents:UIControlEventTouchUpInside];
        });
    }];

#if 0
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        if (self.serviceCenter.audioStreamer.duration) {
            _processBar.width = (self.width*self.serviceCenter.audioStreamer.currentTime)/self.serviceCenter.audioStreamer.duration;
            
        }
    } repeats:YES];
    
    
    
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
