//
//  ImageCollectionViewCell.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.cornerRadius = 3.0;
    self.imageView.layer.masksToBounds = true;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.imageView.layer.borderColor = [[UIColor redColor] CGColor];
        self.imageView.layer.borderWidth = 2.0;
        self.imageView.layer.cornerRadius = 3.0;
        self.imageView.layer.masksToBounds = true;
    } else {
        self.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.imageView.layer.borderWidth = 2.0;
        self.imageView.layer.cornerRadius = 3.0;
        self.imageView.layer.masksToBounds = true;
    }
}

@end
