//
//  PlayerBar.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "PlayerBar.h"
#import "PlayBarActionTableViewCell.h"

@interface PlayerBar () {
    NSTimer*                    _timer;
    UIView*                     _processBar;
    StreamerService*            _streamerService;
    PlayBarActionTableViewCell* _actionCell;
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
    
    _actionCell = [PlayBarActionTableViewCell viewWithNibName:@"PlayBarActionTableViewCell"];
    _actionCell.width = self.width;
    _actionCell.height = self.height;
    _actionCell.top = self.height;
    _actionCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_actionCell.hideButton bk_addEventHandler:^(id sender) {
        [UIView animateWithDuration:0.3f animations:^{
            _actionCell.top = self.height;
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_actionCell];
    
    [self.actionButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* model = [SRV(ArticleService) activeArticleModel];

        [[PlayerBar shareBar] setForceHidden:YES];
        [[UIViewController topViewController].navigationController pushViewController:[WebViewController controllerWithURL:model.url.url didDisappear:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PlayerBar shareBar] setForceHidden:NO];
            });
        }] animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.playButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* model = [SRV(ArticleService) activeArticleModel];

        if (_streamerService.isPlaying) {
            [_streamerService pause];
        } else {
            [_streamerService play:model];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextButton bk_addEventHandler:^(id sender) {
        [SRV(StreamerService) next];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreButton bk_addEventHandler:^(id sender) {
        YDSDKArticleModelEx* model = [SRV(ArticleService) activeArticleModel];
        _actionCell.model = model;
        [UIView animateWithDuration:0.3f animations:^{
            _actionCell.top = 0;
        }];
    } forControlEvents:UIControlEventTouchUpInside];

    _streamerService = SRV(StreamerService);
    _processBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    _processBar.backgroundColor = kThemeColor;
    self.progress = 0;
    [self addSubview:_processBar];
    
    [self.imageView setImage:[UIImage imageWithColor:kThemeColor]];
    [SRV(ArticleService) bk_addObserverForKeyPath:@"activeArticleModel" task:^(id target) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showIfNeed];
            
            YDSDKArticleModelEx* model = [SRV(ArticleService) activeArticleModel];
            [self.imageView sd_setImageWithURL:model.pictureURL.url];
            self.titleLabel.text = model.title;
            self.authorLabel.text = model.author;
            self.speakerLabel.text = model.speaker;
            self.durationLabel.text = [NSString stringWithSeconds:model.duration];
            
            [UIView animateWithDuration:0.3f animations:^{
                _actionCell.top = self.height;
            }];
        });
    }];
    
    [_streamerService bk_addObserverForKeyPath:@"isPlaying" task:^(id target) {
        [self setPlaying:_streamerService.isPlaying];
    }];

    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        if (_streamerService.duration) {
            _processBar.width = (self.width*_streamerService.currentTime)/_streamerService.duration;
        }
    } repeats:YES];
    
#if 0
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
