//
//  FiltersViewController.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "FiltersViewController.h"
#import "ImageCollectionViewCell.h"
#import "CollageManager.h"

@interface FiltersViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *filterCollectionVC;
@property (weak, nonatomic) IBOutlet UIImageView *collageImageView;

@property (strong, nonatomic) NSArray *filters;
@property (strong, nonatomic) UIImage *finalImage;
@property (strong, nonatomic) UIImage *scaledImage;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filters = [NSArray arrayWithObjects:@"FilterTypeNone",
                    @"CISharpenLuminance",
                    @"CIPhotoEffectChrome",
                    @"CIPhotoEffectFade",
                    @"CIPhotoEffectInstant",
                    @"CIPhotoEffectNoir",
                    @"CIPhotoEffectProcess",
                    @"CIPhotoEffectTonal",
                    @"CIPhotoEffectTransfer",
                    @"CISepiaTone",
                    @"CIColorClamp",
                    @"CIColorInvert",
                    @"CIColorMonochrome",
                    @"CISpotLight",
                    @"CIColorPosterize",
                    @"CIBoxBlur",
                    @"CIDiscBlur",
                    @"CIGaussianBlur",
                    @"CIMaskedVariableBlur",
                    @"CIMedianFilter",
                    @"CIMotionBlur",
                    @"CINoiseReduction", nil];
    
    self.collageImageView.image = self.collageImage;
    self.finalImage = self.collageImage;
    self.scaledImage = [self imageWithImage:self.collageImage convertToScale:0.2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImage *)imageWithImage:(UIImage *)image convertToScale:(CGFloat)scale {
    CGSize newSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage *)applyFilter:(UIImage *)image withFilterName:(NSString *)filterName {
    if ([filterName isEqualToString:@"FilterTypeNone"]) {
        return image;
    }
    UIImageOrientation orientation = image.imageOrientation;
    CIImage* cimage = [CIImage imageWithCGImage:image.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:filterName];
    [filter setValue:cimage forKey:kCIInputImageKey];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newPhoto = [UIImage imageWithCGImage:cgimg scale:1.0 orientation:orientation];
    CGImageRelease(cgimg);
    context = nil;
    return newPhoto;
}


#pragma mark UICollectionView - sources

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    NSString *filter = [self.filters objectAtIndex:indexPath.row];
    cell.imageView.image = [self applyFilter:self.scaledImage withFilterName:filter];
    
    return cell;
}


#pragma mark UICollectionView - delegates

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filter = [self.filters objectAtIndex:indexPath.row];
    self.finalImage = [self applyFilter:self.collageImage withFilterName:filter];
    self.collageImageView.image = self.finalImage;
}


#pragma mark UICollectionView - layouts

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_filterCollectionVC.frame.size.height, _filterCollectionVC.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}


#pragma mark IBActions

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(id)sender {
    [[CollageManager sharedInstance] addCollage:self.finalImage];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
