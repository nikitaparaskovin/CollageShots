//
//  MusicItem.m
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

- (instancetype)initWithMediaItem:(MPMediaItem *)item {
    self.musicTitle = item.title ? item.title : NSLocalizedString(@"Unknown", comment: "");
    self.artist = item.artist ? item.artist : NSLocalizedString(@"Unknown", comment: "");
    UIImage *thumbImage = [item.artwork imageWithSize:CGSizeMake(100, 100)];
    if (thumbImage) {
        self.thumb = thumbImage;
    } else {
        self.thumb = [UIImage imageNamed:@"ic_music"];
    }
    self.albumName = item.albumTitle ? item.albumTitle : NSLocalizedString(@"Unknown", comment: "");
    self.fileURL = item.assetURL;
    
    self.durationInSec = item.playbackDuration;
    self.durationInMin = [NSString stringWithFormat:@"%02d:%02d", self.durationInSec / 60, self.durationInSec % 60];
    self.startTime = kCMTimeZero;
    
    return self;
}

@end
