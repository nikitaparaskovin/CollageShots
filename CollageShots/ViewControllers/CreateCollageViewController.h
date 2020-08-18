//
//  CreateCollageViewController.h
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <UIKit/UIKit.h>
@import QBImagePickerController;

NS_ASSUME_NONNULL_BEGIN

@interface CreateCollageViewController : UIViewController< UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, QBImagePickerControllerDelegate >

@end

NS_ASSUME_NONNULL_END
