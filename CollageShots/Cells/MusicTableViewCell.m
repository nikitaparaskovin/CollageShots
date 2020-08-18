//
//  MusicTableViewCell.m
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "MusicTableViewCell.h"

@implementation MusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.labelPlaying.hidden = NO;
    } else {
        self.labelPlaying.hidden = YES;
    }
}

@end
