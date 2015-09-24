//
//  ArticleTableViewCell.m
//  YueduFM
//
//  Created by StarNet on 9/20/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "ArticleTableViewCell.h"

@interface ArticleTableViewCell () {
    RhythmView* _view;
}

@end

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    self.pictureView.layer.cornerRadius = 3.0f;
    self.pictureView.clipsToBounds = YES;
    
    self.detailLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.detailLabel.lineSpacing = 2.0f;
    
    [self.playButton bk_addEventHandler:^(id sender) {
        self.playing = !self.playing;
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self bk_removeAllBlockObservers];
}

#define kColorCount 12
- (NSArray* )colors {
    return @[
             RGBHex(@"#A0F4B2"),
             RGBHex(@"#9FF2F4"),
             RGBHex(@"#A5CAF7"),
             RGBHex(@"#A3B2F6"),
             RGBHex(@"#EEE2AA"),
             RGBHex(@"#DECC85"),
             RGBHex(@"#BEC3C7"),
             RGBHex(@"#F4C600"),
             RGBHex(@"#EA7E00"),
             RGBHex(@"#B8BC00"),
             RGBHex(@"#75C5D6"),
             RGBHex(@"#306056"),
             ];
}

- (void)setModel:(YDSDKArticleModel *)model {
    [self bk_removeAllBlockObservers];
    _model = model;
    
    [self.pictureView sd_setImageWithURL:model.pictureURL.url placeholderImage:[UIImage imageWithColor:self.colors[arc4random()%kColorCount]]];
    self.titleLabel.text = model.title;
    self.authorLabel.text = model.author;
    self.speakerLabel.text = model.speaker;
    self.durationLabel.text = [NSString stringWithSeconds:model.duration];
    self.detailLabel.text = model.abstract;
    self.playing = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (_playing) {
        [self.rhythmView startAnimating];
    } else {
        [self.rhythmView stopAnimating];
    }
}

@end
