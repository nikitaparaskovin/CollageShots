//
//  CollageManager.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "CollageManager.h"

@implementation CollageManager

static CollageManager *_sharedInstance = nil;

+ (CollageManager *)sharedInstance {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[CollageManager alloc] init];
        if (_sharedInstance){
            _sharedInstance.collages = [[NSMutableArray alloc] init];
        }
        if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"collages"]) {
            _sharedInstance.collages = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"collages"]];
        }
    });
    return _sharedInstance;
}

- (void)addCollage:(UIImage *)collage {
    NSData *pngData = UIImagePNGRepresentation(collage);
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int length = 6;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:randomString]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    [_sharedInstance.collages addObject:randomString];
    
    [[NSUserDefaults standardUserDefaults] setObject:_sharedInstance.collages forKey:@"collages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage *)getCollageImage:(NSString *)collageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:collageName];
    
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    
    return image;
}

@end
