//
//  VideoGenerator.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT BOOL const DefaultTransitionShouldAnimate;

FOUNDATION_EXPORT CGSize const DefaultFrameSize;

FOUNDATION_EXPORT NSInteger const DefaultSecPerImage;

FOUNDATION_EXPORT NSInteger const DefaultFrameRate;

FOUNDATION_EXPORT NSInteger const TransitionFrameCount;

FOUNDATION_EXPORT NSInteger const FramesToWaitBeforeTransition;

typedef void(^SuccessBlock)(BOOL success);

@interface VideoGenerator : NSObject

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
      withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                  withCallbackBlock:(SuccessBlock)callbackBlock;

+ (void)addMusicToVideo:(NSURL *)videoURL withAudioURL:(NSURL *)audioURL musicStartTime:(CMTime)musicStartTime
                withCompletionBlock:(void (^_Nonnull)(NSURL *_Nonnull))completionBlock;

@end

NS_ASSUME_NONNULL_END
