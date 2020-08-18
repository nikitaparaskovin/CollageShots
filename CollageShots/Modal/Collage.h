//
//  Collage.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Collage : NSObject

@property (nonatomic, strong) NSMutableArray *collagePhotos;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

+ (Collage *) sharedInstance;

@end

NS_ASSUME_NONNULL_END
