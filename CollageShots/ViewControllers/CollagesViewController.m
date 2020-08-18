//
//  CollagesViewController.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "CollagesViewController.h"
#import "CollageManager.h"
#import "CollageCollectionViewCell.h"
#import "CreateCollageViewController.h"
#import "VideoViewController.h"
#import "VideoGenerator.h"

@interface CollagesViewController () < UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (weak, nonatomic) IBOutlet UICollectionView *collageCollection;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@property (strong, nonatomic) CollageManager *collages;

@end

@implementation CollagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collages = [CollageManager sharedInstance];
    
    if (self.collages.collages.count > 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.emptyLabel.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.collages.collages.count > 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.emptyLabel.hidden = NO;
    }
    [self.collageCollection reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UICollectionView - layouts

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collageCollection.frame.size.width / 2.0f, self.collageCollection.frame.size.width / 2.0f);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


#pragma mark UICollectionView - sources

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.collages.collages.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollageCollectionViewCell *cell = (CollageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:@"CollageCollectionViewCell" forIndexPath:indexPath];
    NSString *collageName = [self.collages.collages objectAtIndex:indexPath.row];
    cell.collageView.image = [self.collages getCollageImage:collageName];
    
    return cell;
}


#pragma mark UICollectionView - delegates

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark IBActions

- (IBAction)actionNew:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateCollageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CreateCollageViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionFilm:(id)sender {
    
    if (self.collages.collages.count > 0) {
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"temp.mp4"]];
        
        NSMutableArray *collageImages = [[NSMutableArray alloc] init];
        for (NSString *collageName in self.collages.collages) {
            UIImage *collageImage = [self.collages getCollageImage:collageName];
            [collageImages addObject:collageImage];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [VideoGenerator saveVideoToPhotosWithImages:collageImages animateTransitions:YES withCallbackBlock:^(BOOL success) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        VideoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
                        vc.videoURL = [NSURL fileURLWithPath:tempPath];
                        [self.navigationController pushViewController:vc animated:YES];
                    });
                }
            }];
        });
    }
}


@end
