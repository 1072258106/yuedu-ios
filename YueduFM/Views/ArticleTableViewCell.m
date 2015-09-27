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


- (void)setModel:(YDSDKArticleModelEx* )model {
    [self bk_removeAllBlockObservers];
    _model = model;
    
    [self.pictureView sd_setImageWithURL:model.pictureURL.url placeholderImage:[UIImage imageWithColor:[UIColor colors][model.aid%[[UIColor colors] count]]]];
    self.titleLabel.text = model.title;
    self.authorLabel.text = model.author;
    self.speakerLabel.text = model.speaker;
    self.durationLabel.text = [NSString stringWithSeconds:model.duration];
    self.detailLabel.text = model.abstract;
    self.playing = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
