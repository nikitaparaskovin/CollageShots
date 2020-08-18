//
//  MusicLibrary.m
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "MusicLibrary.h"

@implementation MusicLibrary

static MusicLibrary *_sharedInstance = nil;

+ (MusicLibrary *)sharedInstance
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MusicLibrary alloc] init];
        if (_sharedInstance){
            _sharedInstance.musics = [[NSMutableArray alloc] init];
        }
    });
    return _sharedInstance;
}

- (void)askAuthorization:(void (^)(MPMediaLibraryAuthorizationStatus))completionBlock {
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        switch (status) {
                case MPMediaLibraryAuthorizationStatusNotDetermined:
                {
                [self askAuthorization:^(MPMediaLibraryAuthorizationStatus authStatus) {
                    if (completionBlock) completionBlock(authStatus);
                }];
                }
                break;
                case MPMediaLibraryAuthorizationStatusDenied:
                    if (completionBlock) completionBlock(status);
                break;
                case MPMediaLibraryAuthorizationStatusRestricted:
                    if (completionBlock) completionBlock(status);
                break;
                case MPMediaLibraryAuthorizationStatusAuthorized:
                {
                    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
                    NSArray *itemsFromGenericQuery = [everything items];
                    for (MPMediaItem *song in itemsFromGenericQuery) {
                        [_sharedInstance.musics addObject:[[MusicItem alloc] initWithMediaItem:song]];
                    }
                    if (completionBlock) completionBlock(status);
                }
                break;
            default:
                break;
        }
    }];
}

@end
