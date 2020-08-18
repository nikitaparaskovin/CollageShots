//
//  FiltersViewController.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FiltersViewController : UIViewController< UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout >

@property (strong, nonatomic) UIImage *collageImage;

@end

NS_ASSUME_NONNULL_END
