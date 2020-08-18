//
//  MusicItem.h
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicItem : NSObject

@property (strong, nonatomic) NSString *musicTitle;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) UIImage * thumb;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *durationInMin;
@property (nonatomic) int durationInSec;
@property (strong, nonatomic) NSURL * _Nullable fileURL;
@property (nonatomic) CMTime startTime;

- (instancetype)initWithMediaItem:(MPMediaItem *)item;

@end

NS_ASSUME_NONNULL_END
