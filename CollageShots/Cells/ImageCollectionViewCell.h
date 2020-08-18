//
//  ImageCollectionViewCell.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UIView *viewForDrawing;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
