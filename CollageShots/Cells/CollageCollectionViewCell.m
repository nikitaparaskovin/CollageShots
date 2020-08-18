//
//  CollageCollectionViewCell.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "CollageCollectionViewCell.h"

@implementation CollageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.collageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.collageView.layer.borderWidth = 1.0;
    self.collageView.layer.cornerRadius = 3.0;
    self.collageView.layer.masksToBounds = true;
}

@end
