//
//  VideoGenerator.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "VideoGenerator.h"

CGSize const DefaultFrameSize                             = (CGSize){480, 480};

NSInteger const DefaultSecPerImage                        = 3;
NSInteger const DefaultFrameRate                          = 1;
NSInteger const TransitionFrameCount                      = 50;
NSInteger const FramesToWaitBeforeTransition              = 40;

BOOL const DefaultTransitionShouldAnimate = YES;

@implementation VideoGenerator

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:DefaultFrameRate
                  animateTransitions:DefaultTransitionShouldAnimate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:DefaultFrameRate
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator videoFromImages:images
                              toPath:path
                            withSize:DefaultFrameSize
                             withFPS:fps
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator videoFromImages:images
                              toPath:path
                            withSize:size
                             withFPS:DefaultFrameRate
                  animateTransitions:animate
                   withCallbackBlock:callbackBlock];
}

+ (void)videoFromImages:(NSArray *)images
                 toPath:(NSString *)path
               withSize:(CGSize)size
                withFPS:(int)fps
     animateTransitions:(BOOL)animate
      withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator writeImageAsMovie:images
                                toPath:path
                                  size:size
                                   fps:fps
                    animateTransitions:animate
                     withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                              animateTransitions:DefaultTransitionShouldAnimate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator saveVideoToPhotosWithImages:images
                                        withSize:size
                                         withFPS:DefaultFrameRate
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    [VideoGenerator saveVideoToPhotosWithImages:images
                                        withSize:DefaultFrameSize
                                         withFPS:fps
                              animateTransitions:animate
                               withCallbackBlock:callbackBlock];
}

+ (void)saveVideoToPhotosWithImages:(NSArray *)images
                           withSize:(CGSize)size
                            withFPS:(int)fps
                 animateTransitions:(BOOL)animate
                  withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"temp.mp4"]];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:NULL];
    
    [VideoGenerator videoFromImages:images
                              toPath:tempPath
                            withSize:size
                             withFPS:fps
                  animateTransitions:animate
                   withCallbackBlock:^(BOOL success) {
                       
                       if (success) {
//                           UISaveVideoAtPathToSavedPhotosAlbum(tempPath, self, nil, nil);
                       }
                       
                       if (callbackBlock) {
                           callbackBlock(success);
                       }
                   }];
}

+ (void)writeImageAsMovie:(NSArray *)array
                   toPath:(NSString*)path
                     size:(CGSize)size
                      fps:(int)fps
       animateTransitions:(BOOL)shouldAnimateTransitions
        withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSLog(@"%@", path);
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    if (error) {
        if (callbackBlock) {
            callbackBlock(NO);
        }
        return;
    }
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:size.height]};
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer;
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);
    
    CMTime presentTime = CMTimeMake(0, fps);
    
    int i = 0;
    while (1)
    {
        
        if(writerInput.readyForMoreMediaData){
            
            presentTime = CMTimeMake(DefaultSecPerImage * i, fps);
            
            if (i >= [array count]) {
                buffer = NULL;
            } else {
                buffer = [VideoGenerator pixelBufferFromCGImage:[array[i] CGImage] size:DefaultFrameSize];
            }
            
            if (buffer) {
                //append buffer
                
                BOOL appendSuccess = [VideoGenerator appendToAdapter:adaptor
                                                          pixelBuffer:buffer
                                                               atTime:presentTime
                                                            withInput:writerInput];
                NSAssert(appendSuccess, @"Failed to append");
                
                if (shouldAnimateTransitions && i + 1 < array.count) {
                    
                    //Create time each fade frame is displayed
                    CMTime fadeTime = CMTimeMake(DefaultSecPerImage, fps*TransitionFrameCount);
                    
                    //Add a delay, causing the base image to have more show time before fade begins.
                    for (int b = 0; b < FramesToWaitBeforeTransition; b++) {
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                    }
                    
                    //Adjust fadeFrameCount so that the number and curve of the fade frames and their alpha stay consistant
                    NSInteger framesToFadeCount = TransitionFrameCount - FramesToWaitBeforeTransition;
                    
                    //Apply fade frames
                    for (double j = 1; j < framesToFadeCount; j++) {
                        
                        buffer = [VideoGenerator crossFadeImage:[array[i] CGImage]
                                                         toImage:[array[i + 1] CGImage]
                                                          atSize:DefaultFrameSize
                                                       withAlpha:j/framesToFadeCount];
                        
                        BOOL appendSuccess = [VideoGenerator appendToAdapter:adaptor
                                                                  pixelBuffer:buffer
                                                                       atTime:presentTime
                                                                    withInput:writerInput];
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                        
                        NSAssert(appendSuccess, @"Failed to append");
                    }
                }
                
                i++;
            } else {
                
                //Finish the session:
                [writerInput markAsFinished];
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"Successfully closed video writer");
                    if (videoWriter.status == AVAssetWriterStatusCompleted) {
                        if (callbackBlock) {
                            callbackBlock(YES);
                        }
                    } else {
                        if (callbackBlock) {
                            callbackBlock(NO);
                        }
                    }
                }];
                
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                break;
            }
        }
    }
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
                                      size:(CGSize)imageSize
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           imageSize.width,
                                           imageSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (CVPixelBufferRef)crossFadeImage:(CGImageRef)baseImage
                           toImage:(CGImageRef)fadeInImage
                            atSize:(CGSize)imageSize
                         withAlpha:(CGFloat)alpha
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGRect drawRect = CGRectMake(0,
                                 0,
                                 imageSize.width,
                                 imageSize.height);
    
    CGContextDrawImage(context, drawRect, baseImage);
    
    CGContextBeginTransparencyLayer(context, nil);
    CGContextSetAlpha( context, alpha );
    CGContextDrawImage(context, drawRect, fadeInImage);
    CGContextEndTransparencyLayer(context);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput
{
    while (!writerInput.readyForMoreMediaData) {
        usleep(1);
    }
    
    return [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
}

+ (void)addMusicToVideo:(NSURL *)videoURL withAudioURL:(nonnull NSURL *)audioURL musicStartTime:(CMTime)musicStartTime withCompletionBlock:(void (^ _Nonnull)(NSURL * _Nonnull))completionBlock {
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(musicStartTime, videoAsset.duration);

    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int length = 6;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"final%@.mov", randomString]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    }
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Do export finish stuff
             if (completionBlock) {
                 completionBlock(outputFileUrl);
             }
             if ([[NSFileManager defaultManager] fileExistsAtPath:videoURL.path]){
                 [[NSFileManager defaultManager] removeItemAtPath:videoURL.path error:nil];
             }
         });
     }];
}

@end
