//
//  CreateCollageViewController.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "CreateCollageViewController.h"
#import "Collage.h"
#import "ImageCollectionViewCell.h"
#import "FiltersViewController.h"

@interface CreateCollageViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *selectedPhotoCV;
@property (weak, nonatomic) IBOutlet UICollectionView *modesCV;

@property (strong, nonatomic) Collage *collage;
@property (weak, nonatomic) IBOutlet UIView *collageFrame;

@property BOOL isFreeForm;
@property (weak, nonatomic) UIImageView *movingImage;
@property (strong, nonatomic) UIImageView *movingCell;
@property (strong, nonatomic) NSMutableArray *templates;
@property (strong, nonatomic) UIColor *currentColor;
@property (strong, nonatomic) UIImageView *zoomedImageView;

@end

@implementation CreateCollageViewController

#pragma mark Variables
NSInteger photoIndex;
NSInteger selectedPhotoCount;
NSInteger borderWidth;
float borderConer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isFreeForm = YES;
    borderWidth = 3;
    borderConer = 0;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_selectedPhotoCV setCollectionViewLayout:flowLayout];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .3; //seconds
    lpgr.delegate = self;
    [_selectedPhotoCV addGestureRecognizer: lpgr];
    
    [_collageFrame addSubview:_movingImage];
    
    
    UICollectionViewFlowLayout *flowLayoutForModes = [[UICollectionViewFlowLayout alloc] init];
    [flowLayoutForModes  setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_modesCV setCollectionViewLayout:flowLayoutForModes];
    
    _currentColor = [UIColor whiteColor];

    _collageFrame.backgroundColor = [UIColor clearColor];//mainBackgroundColor ;//[UIColor whiteColor];//lightGrayColor
    _collageFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    _collageFrame.layer.borderWidth = 1.0f;
    
    _collage = [Collage sharedInstance];
    selectedPhotoCount = [_collage.selectedPhotos count];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"collage_templates" ofType:@"txt"];
    
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSAssert(myJSON, @"File collage_templates.txt couldn't be read!");
    
    NSData *data = [myJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    _templates = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (NSDictionary *i in [[dict objectForKey:@"collage_templates"] objectForKey:@"templates"]) {
        [_templates addObject:i];
    }
    
    [self.modesCV selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
    
    _isFreeForm = NO;
    [self deleteScrolls];
    [self deleteUIImageView];
    [self addScrollsWithIndex:0];
    _collageFrame.layer.borderWidth = 0.0f;
    _collageFrame.layer.cornerRadius = 0.0f;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
    for (NSInteger i = selectedPhotoCount; i < [_collage.selectedPhotos count]; i++) {
        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_selectedPhotoCV insertItemsAtIndexPaths:arrayWithIndexPaths];
    selectedPhotoCount = [_collage.selectedPhotos count];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Gesture Recognizer Selectors

- (void) handleLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    CGPoint locationPointInCollection = [longRecognizer locationInView:_selectedPhotoCV];
    CGPoint locationPointInView = [longRecognizer locationInView:self.view];
    
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *indexPathOfMovingCell = [_selectedPhotoCV indexPathForItemAtPoint:locationPointInCollection];
        if (indexPathOfMovingCell.row == [_collage.selectedPhotos count]) {
            return;
        }
        
        photoIndex = indexPathOfMovingCell.row;
        
        NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPathOfMovingCell.row];
        UIImage *image = [[UIImage alloc] init];
        id i = [photoDict objectForKey:@"smallImage"];
        if ([i isKindOfClass:[NSData class]]) {
            image = [UIImage imageWithData:(NSData *) i];
        } else {
            image = (UIImage *) i;
        }
        CGRect frame = CGRectMake(locationPointInView.x, locationPointInView.y, 150.0f, 150.0f);
        _movingCell = [[UIImageView alloc] initWithFrame:frame];
        _movingCell.image = image;
        [_movingCell setCenter:locationPointInView];
        _movingCell.layer.borderWidth = 5.0f;
        _movingCell.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:_movingCell];
        
    }
    
    if (longRecognizer.state == UIGestureRecognizerStateChanged) {
        [_movingCell setCenter:locationPointInView];
    }
    
    if (longRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frameRelativeToParentCollageFrame = [_collageFrame convertRect:_collageFrame.bounds
                                                                       toView:self.view];
        if (CGRectContainsPoint( frameRelativeToParentCollageFrame, _movingCell.center)){
            if (_isFreeForm){
                CGPoint originInCollageView = [_collageFrame convertPoint:_movingCell.center fromView:self.view];
                float width = (_collageFrame.bounds.size.width - 5)/2;
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
                [self holdInContainer:imgView withIndex:photoIndex];
                [self tuneImageView:imgView withCenterPont: originInCollageView];
                [_collageFrame addSubview:imgView];
                [_collageFrame bringSubviewToFront:imgView];
                //[self.movingCell removeFromSuperview];
            } else{
                for (id i in _collageFrame.subviews){
                    if( [i isKindOfClass:[UIScrollView class]]){
                        UIScrollView *tmpScroll = (UIScrollView *)i;
                        CGRect frameRelativeToParent= [tmpScroll convertRect: tmpScroll.bounds
                                                                      toView:self.view];
                        if (CGRectContainsPoint( frameRelativeToParent, _movingCell.center)){
                            for (id y in tmpScroll.subviews){
                                if( [y isKindOfClass:[UIImageView class]]){
                                    UIImageView *imgView = y;
                                    if (imgView.tag!=0){
                                        [self holdInContainer:imgView withIndex: photoIndex];
                                        tmpScroll.contentSize = imgView.bounds.size;
                                        [_movingCell removeFromSuperview];
                                        [tmpScroll setNeedsLayout];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else{
            [_movingCell removeFromSuperview];
        }
    }
}

- (void)bringSubviewToFront:(UITapGestureRecognizer *) gesture{
    CGPoint locationPointInView = [gesture locationInView:_collageFrame];
    for (UIView *i in _collageFrame.subviews){
        if([i isKindOfClass:[UIImageView class]]){
            UIImageView *img = (UIImageView*)i;
            CGRect frameRelativeToParent = [img convertRect:img.bounds
                                                     toView:_collageFrame];
            if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
                _movingImage = (UIImageView*)i;
                [_collageFrame bringSubviewToFront:_movingImage];
            }
        }
    }
}

- (void) moveImageInCollage: (UIPanGestureRecognizer *) gesture{
    CGPoint locationPointInView = [gesture locationInView: _collageFrame];
    CGPoint locationPointInSuperView = [gesture locationInView:self.view];
    if (gesture.state ==  UIGestureRecognizerStateBegan){
        for (UIView *i in _collageFrame.subviews){
            if([i isKindOfClass:[UIImageView class]]){
                UIImageView *img = (UIImageView*)i;
                CGRect frameRelativeToParent = [img convertRect:img.bounds
                                                         toView:_collageFrame];
                if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
                    _movingImage = img;//(UIImageView*)i;
                    _movingImage.tag = [_collage.collagePhotos indexOfObject: img.image];
                    [_collageFrame bringSubviewToFront:_movingImage];
                }
            }
        }
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGRect frameRelativeToParent = [_movingImage convertRect:_movingImage.bounds
                                                          toView:_collageFrame];
        if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
            _movingImage.center =locationPointInView;
        }
    }
    if(gesture.state == UIGestureRecognizerStateEnded){
        CGRect frameRelativeToParent = [_collageFrame convertRect:_collageFrame.bounds
                                                           toView:self.view];
        if (! CGRectContainsPoint( frameRelativeToParent , locationPointInSuperView)){
            [_collage.collagePhotos removeObjectAtIndex:_movingImage.tag];
            [_movingImage removeFromSuperview];
        }
    }
}

- (void)chooseFromLibrary:(UITapGestureRecognizer *) gesture{

}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    UIScrollView *scroll = (UIScrollView *) recognizer.view;
    for (id y in scroll.subviews){
        if( [y isKindOfClass:[UIImageView class]]){
            UIImageView *imgView = y;
            if (imgView.tag!=0){
                _zoomedImageView = imgView;
            }
        }
    }
    CGPoint pointInView = [recognizer locationInView:_zoomedImageView];
    
    CGFloat newZoomScale = scroll.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, scroll.maximumZoomScale);
    
    CGSize scrollViewSize = scroll.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [scroll zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    UIScrollView *scroll = (UIScrollView *) recognizer.view;
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = scroll.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, scroll.minimumZoomScale);
    [scroll setZoomScale:newZoomScale animated:YES];
}


#pragma mark - ScrollView delegates

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return  _zoomedImageView;
}


#pragma mark UICollectionView - sources

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (view == _selectedPhotoCV) {
        return [_collage.selectedPhotos count] + 1;
    } else if (view == _modesCV){
        return [_templates count];
    } else return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    if (cv == _modesCV){
        if(cell.isSelected){
            cell.layer.borderWidth = 2.0f;
            cell.layer.borderColor = self.navigationController.navigationBar.tintColor.CGColor;
        } else {
            cell.layer.borderWidth = 0.0f;
        }
        [cell.imageView setHidden:YES];
        cell.viewForDrawing.frame = cell.bounds;
        cell.viewForDrawing.backgroundColor = [UIColor clearColor];
        cell.viewForDrawing.layer.borderWidth = 2.0f;
        cell.viewForDrawing.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.viewForDrawing.clearsContextBeforeDrawing = YES;
        [cell.viewForDrawing.layer setSublayers:nil];
        
        NSDictionary *dict = [_templates objectAtIndex: indexPath.row];
        NSArray *templ_array = [dict objectForKey:@"small_template"];
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        for (NSDictionary *d in templ_array) {
            [path moveToPoint:CGPointMake( [[d objectForKey:@"start_x"] floatValue], [[d objectForKey:@"start_y"] floatValue])];
            [path addLineToPoint:CGPointMake( [[d objectForKey:@"end_x"] floatValue], [[d objectForKey:@"end_y"] floatValue])];
        }
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 2.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [cell.viewForDrawing.layer addSublayer:shapeLayer];
        [cell setNeedsDisplay];
    } else {
        if (indexPath.row == [_collage.selectedPhotos count]) {
            cell.image = [UIImage imageNamed:@"ic_gallery"];
        } else {
            NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPath.row];
            id i = [photoDict objectForKey:@"smallImage"];
            if ([i isKindOfClass:[NSData class]]) {
                cell.image = [UIImage imageWithData:(NSData *) i];
            } else {
                cell.image = (UIImage *) i;
            }
        }
    }
    return cell;
}


#pragma mark UICollectionView - delegates

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =  [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _modesCV){
        _isFreeForm=NO;
        [self deleteScrolls];
        [self deleteUIImageView];
        [self addScrollsWithIndex:indexPath.row];
        _collageFrame.layer.borderWidth = 0.0f;
        _collageFrame.layer.cornerRadius = 0.0f;
        
        cell.layer.borderWidth = 2.0f;
        cell.layer.borderColor = self.navigationController.navigationBar.tintColor.CGColor;
    } else {
        if (indexPath.row == [_collage.selectedPhotos count]) {
            QBImagePickerController *imagePickerController = [QBImagePickerController new];
            imagePickerController.delegate = self;
            imagePickerController.allowsMultipleSelection = YES;
            imagePickerController.mediaType = QBImagePickerMediaTypeImage;
            imagePickerController.maximumNumberOfSelection = 6;
            imagePickerController.showsNumberOfSelectedAssets = YES;
            
            [self presentViewController:imagePickerController animated:YES completion:NULL];
        }
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =  [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _modesCV){
        _isFreeForm=YES;
        cell.layer.borderWidth = 0.0f;
    }
}


#pragma mark UICollectionView - layouts

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selectedPhotoCV) {
        return CGSizeMake(_selectedPhotoCV.frame.size.height, _selectedPhotoCV.frame.size.height);
    } else return CGSizeMake(96.0f, 96.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _modesCV) { return 30.0f; }
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == _modesCV){
        NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        NSIndexPath *index = [[NSIndexPath alloc] initWithIndex:0];
        CGSize size = [self collectionView:_modesCV
                                    layout:collectionViewLayout
                    sizeForItemAtIndexPath: index];
        CGFloat cellWidth = size.width;
        CGFloat totalCellWidth = cellWidth*cellCount +(((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing * (cellCount - 1));
        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;
        if( totalCellWidth<contentWidth )
        {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(0, padding, 0, padding);
        }
    }
    return UIEdgeInsetsMake(0,5,0,5);  // top, left, bottom, right
}


#pragma mark QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    NSMutableArray *newImages = [[NSMutableArray alloc] init];
     __block UIImage *ima;
    
    for (PHAsset *asset in assets) {
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset
                           targetSize:CGSizeMake(320, 320)
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            ima = image;
                            self.movingImage.image = ima;
                            [self.collage.collagePhotos addObject:ima];
                            NSDictionary *photoDictionary = @{@"info": [NSNull null], @"smallImage": ima};
                            [self.collage.selectedPhotos addObject:photoDictionary];
                            
                            [newImages addObject:ima];
                            if (newImages.count == assets.count) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self dismissViewControllerAnimated:YES completion:NULL];
                                });
                            }
                        }];
    }
    
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark Utilities

- (void)addScrollsWithIndex: (NSInteger) index {
    NSDictionary *dict = [_templates objectAtIndex: index];
    NSArray *templ_array = [dict objectForKey:@"scrolls"];
    int i =0;
    for (NSDictionary *d in templ_array) {
        float x = [[d objectForKey:@"x"] floatValue];
        float y = [[d objectForKey:@"y"] floatValue];
        float width = [[d objectForKey:@"width"] floatValue];
        float height = [[d objectForKey:@"height"] floatValue];
        CGRect frame = CGRectMake(x, y, width, height);
        
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
        scroll.backgroundColor = [UIColor clearColor];
        [_collageFrame addSubview:scroll];
        [self tuneScroll:scroll withContentSize:CGSizeMake(width, height) withScrollIndex:i];
        i+=1;
    }
    
}

- (void) deleteScrolls {
    for (id i in _collageFrame.subviews){
        if( [i isKindOfClass:[UIScrollView class]]){
            [i removeFromSuperview];
        }
    }
}

- (void)reesteblishImageViews {
    float x = 75.0f;
    float y = 75.0f;
    float offset = _collageFrame.bounds.size.width/ [_collage.collagePhotos count];
    for (UIImage *img in _collage.collagePhotos){
        float width = (_collageFrame.bounds.size.width - 5)/2;
        UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        float s = 1.0f;
        if (img.size.height> img.size.width) {
            s = img.size.height/img.size.width;
            CGRect newRect = CGRectMake(newImageView.frame.origin.x, newImageView.frame.origin.y, newImageView.frame.size.width, newImageView.frame.size.height*s);
            newImageView.frame = newRect;
        } else{
            s = img.size.width/img.size.height;
            CGRect newRect = CGRectMake(newImageView.frame.origin.x, newImageView.frame.origin.y, newImageView.frame.size.width*s, newImageView.frame.size.height);
            newImageView.frame = newRect;
        }
        newImageView.image = img;
        [self tuneImageView:newImageView withCenterPont:CGPointMake(x, y)];
        [_collageFrame addSubview:newImageView];
        [_collageFrame bringSubviewToFront:newImageView];
        x += offset;
        y += offset;
    }
}

- (void) deleteUIImageView {
    for (id i in _collageFrame.subviews){
        if( [i isKindOfClass:[UIImageView class]]){
            [i removeFromSuperview];
        }
    }
}

- (void)tuneScroll: (UIScrollView *)scroll withContentSize: (CGSize) size withScrollIndex: (NSInteger) index
{
    float biggestSide = (size.height>size.width)? size.height : size.width;
    scroll.contentSize = CGSizeMake(biggestSide, biggestSide);
    CGRect frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), scroll.contentSize};
    UIImageView *imView = [[UIImageView alloc] initWithFrame: frame];
    //UIScrollView by default contains 2 UIImageViews as subviews for scroll indicators.
    //so we need tag for mark ours
    imView.tag = 101;
    //in case wrong array index
    @try {
        float s = 1.0f;
        UIImage *img = [_collage.collagePhotos objectAtIndex:index];
        NSLog(@"OLD SIZE w=%f, h=%f", imView.frame.size.width, imView.frame.size.height);
        if (img.size.height> img.size.width) {
            s = img.size.height/img.size.width;
            CGRect newRect = CGRectMake(imView.frame.origin.x, imView.frame.origin.y, imView.frame.size.width, imView.frame.size.height*s);
            imView.frame = newRect;
        } else{
            s = img.size.width/img.size.height;
            CGRect newRect = CGRectMake(imView.frame.origin.x, imView.frame.origin.y, imView.frame.size.width*s, imView.frame.size.height);
            imView.frame = newRect;
        }
        NSLog(@"NEW SIZE w=%f, h=%f", imView.frame.size.width, imView.frame.size.height);
        scroll.contentSize = imView.frame.size;
        imView.image = img;
        
    }
    @catch (NSException *exception) {
        //do nothing
    }
    
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [scroll addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [scroll addGestureRecognizer:twoFingerTapRecognizer];
    
    scroll.delegate = self;
    scroll.layer.borderWidth = borderWidth;
    scroll.layer.borderColor = _currentColor.CGColor;
    CGFloat scaleWidth = scroll.frame.size.width / scroll.contentSize.width;
    CGFloat scaleHeight = scroll.frame.size.height / scroll.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    scroll.minimumZoomScale = 1.0f;
    scroll.zoomScale = minScale;
    scroll.maximumZoomScale = 2.0f;
    [scroll addSubview:imView];
}

- (void) tuneImageView: (UIImageView *)imageView withCenterPont: (CGPoint) centerPont {
    
    imageView.center = centerPont;
    [imageView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImageInCollage:)];
    pan.delegate = self;
    [imageView addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bringSubviewToFront:)];
    tap.delegate = self;
    [imageView addGestureRecognizer: tap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseFromLibrary:)];
    doubleTap.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTap];
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 5.0f;
}


- (void) holdInContainer: (UIImageView *) container withIndex: (NSInteger) i {
    container.alpha = 0.0;
    container.image = _movingCell.image;
    
    //download big imgage's version
    NSDictionary *photoDict = _collage.selectedPhotos[i];
    id photo = [photoDict objectForKey:@"info"];
    if (photo != [NSNull null]){
        CGPoint centerPoint = _movingCell.center;
        [UIView animateWithDuration: 0.5f
                         animations:^{
                             CGRect frame = self.movingCell.frame;
                             frame.size.width -= frame.size.width - 1.0f;
                             frame.size.height -= frame.size.height -  1.0f;
                             self.movingCell.frame = frame;
                             self.movingCell.center = centerPoint;
                         }
                         completion:^(BOOL finished){
                             [self.movingCell removeFromSuperview];
                         }];
    } else {
        UIImage *img =[[UIImage alloc] init];
        id i = [photoDict objectForKey:@"smallImage"];
        if ([i isKindOfClass:[NSData class]]) {
            img = [UIImage imageWithData:(NSData *) i];
        } else {
            img = (UIImage *) i;
        }
        float s = 1.0f;
        if (img.size.height> img.size.width) {
            s = img.size.height/img.size.width;
            CGRect newRect = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height*s);
            container.frame = newRect;
        } else{
            s = img.size.width/img.size.height;
            CGRect newRect = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width*s, container.frame.size.height);
            container.frame = newRect;
        }
        container.image = img;
        CGPoint centerPoint = _movingCell.center;
        [_collage.collagePhotos addObject:img];
        [UIView animateWithDuration: 0.5f
                         animations:^{
                             container.alpha = 1.0f;
                             CGRect frame = self.movingCell.frame;
                             frame.size.width -= frame.size.width - 1.0f;
                             frame.size.height -= frame.size.height -  1.0f;
                             self.movingCell.frame = frame;
                             self.movingCell.center = centerPoint;}
                         completion:^(BOOL finished){
                             [self.movingCell removeFromSuperview];
                         }];
    }
}

- (UIImage *) makeImage {
    UIGraphicsBeginImageContextWithOptions(_collageFrame.bounds.size, NO, 0.0);
    [_collageFrame.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark IBActions

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionNext:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FiltersViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"FiltersViewController"];
    vc.collageImage = [self makeImage];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
