//
//  MusicLibrary.h
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicLibrary : NSObject

@property (strong, nonatomic) NSMutableArray<MusicItem *> *musics;

+ (MusicLibrary *)sharedInstance;
- (void)askAuthorization:(void (^_Nonnull)(MPMediaLibraryAuthorizationStatus))completionBlock;

@end

NS_ASSUME_NONNULL_END
