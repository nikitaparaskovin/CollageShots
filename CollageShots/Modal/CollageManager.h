//
//  CollageManager.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollageManager : NSObject

@property (nonatomic, strong) NSMutableArray *collages;

+ (CollageManager *) sharedInstance;
- (void)addCollage:(UIImage *)collage;
- (UIImage *)getCollageImage:(NSString *)collageName;

@end

NS_ASSUME_NONNULL_END
