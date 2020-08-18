//
//  MusicViewController.h
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MusicViewControllerDelegate

@optional

// Callback for selected music
- (void)didSelectMusic:(MusicItem *)music;

@end

@interface MusicViewController : UIViewController

@property (strong, nonatomic) NSObject<MusicViewControllerDelegate>* controllerDelegate;

@end

NS_ASSUME_NONNULL_END
