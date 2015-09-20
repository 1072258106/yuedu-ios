//
//  ArticleTableViewCell.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleTableViewCell.h"

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    self.pictureView.layer.cornerRadius = 3.0f;
    self.pictureView.clipsToBounds = YES;
    
    self.detailLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.detailLabel.lineSpacing = 2.0f;
    
    [self.playButton bk_addEventHandler:^(id sender) {
        if (self.playing) {
            [__serviceCenter articleStop];
        } else {
            [__serviceCenter articlePlay:self.model statusChanged:^(DOUAudioStreamerStatus status) {
                
            }];
        }
        self.playing = !self.playing;
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self bk_removeAllBlockObservers];
}

- (void)setModel:(YDSDKArticleModel *)model {
    [self bk_removeAllBlockObservers];
    
    _model = model;
    
    [self.pictureView sd_setImageWithURL:model.pictureURL.url];
    self.titleLabel.text = model.title;
    self.authorLabel.text = model.author;
    self.speakerLabel.text = model.speaker;
    self.durationLabel.text = [NSString stringWithSeconds:model.duration];
    self.detailLabel.text = model.abstract;
    
    if (__serviceCenter.audioStreamer.status == DOUAudioStreamerBuffering
        || __serviceCenter.audioStreamer.status == DOUAudioStreamerPlaying) {
        self.playing = [model.audioURL isEqualToString:__serviceCenter.audioStreamer.url.absoluteString];
    } else {
        self.playing = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    self.playButton.selected = playing;
}

@end
