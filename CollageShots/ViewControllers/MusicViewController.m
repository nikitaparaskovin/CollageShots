//
//  MusicViewController.m
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "MusicViewController.h"
#import "MusicTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
@import SCWaveformView;

@interface MusicViewController () < UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate >

@property (weak, nonatomic) IBOutlet UITableView *musicTableView;
@property (weak, nonatomic) IBOutlet UIImageView *musicThumbView;
@property (weak, nonatomic) IBOutlet SCScrollableWaveformView *waveformView;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@property (strong, nonatomic) MusicItem * _Nullable selectedMusic;
@property (strong, nonatomic) AVAudioPlayer * audioPlayer;

@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[MusicLibrary sharedInstance] askAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        if(status == MPMediaLibraryAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.musicTableView reloadData];
            });
        }
    }];
    
    self.waveformView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setWaveformView {
    self.waveformView.contentInset = UIEdgeInsetsMake(0, self.waveformView.frame.size.width / 2.0f, 0, self.waveformView.frame.size.width / 2.0f);

    self.waveformView.showsHorizontalScrollIndicator = NO;
    
    AVAsset *asset = [AVURLAsset assetWithURL:self.selectedMusic.fileURL];
    self.waveformView.waveformView.asset = asset;
    
    self.waveformView.waveformView.normalColor = [UIColor whiteColor];
    self.waveformView.waveformView.progressColor = [UIColor whiteColor];
    
    self.waveformView.waveformView.precision = 0.1;
    self.waveformView.waveformView.lineWidthRatio = 0.2;
    self.waveformView.waveformView.channelsPadding = 10;
    
    self.waveformView.waveformView.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(self.selectedMusic.durationInSec * 0.2, 10000));
    
    [self.waveformView setContentOffset:CGPointMake(-self.waveformView.frame.size.width / 2.0f, 0)];

    NSString *timeString = [NSString stringWithFormat:@"%@ 00:00, %02d:%02d %@", NSLocalizedString(@"Start", comment: ""), self.selectedMusic.durationInSec / 60, self.selectedMusic.durationInSec % 60, NSLocalizedString(@"Remained", comment: "")];
    self.labelTime.text = timeString;
    self.selectedMusic.startTime = kCMTimeZero;

}

- (void)playMusic {
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.selectedMusic.fileURL error:nil];
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer play];
}


#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MusicLibrary sharedInstance].musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicTableViewCell *cell = (MusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MusicTableViewCell"];
    if (cell == nil) {
        cell = (MusicTableViewCell *)[[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:@"MusicTableViewCell"];
    }
    MusicItem *item = [MusicLibrary sharedInstance].musics[indexPath.row];
    
    cell.thumbImageView.image = item.thumb;
    cell.titleLabel.text = item.musicTitle;
    cell.durationLabel.text = item.durationInMin;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMusic = [MusicLibrary sharedInstance].musics[indexPath.row];
    [self playMusic];
    [self setWaveformView];
    self.musicThumbView.image = self.selectedMusic.thumb;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 80.0f;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.waveformView) {
        CGFloat offset = (scrollView.contentOffset.x + self.waveformView.frame.size.width / 2.0f) / scrollView.contentSize.width;
        
        int startTimeInSec = self.selectedMusic.durationInSec * offset;
        int leftTimeInSec = self.selectedMusic.durationInSec - startTimeInSec;
        
        self.selectedMusic.startTime = CMTimeMake(startTimeInSec, 1);

        NSString *timeString = [NSString stringWithFormat:@"%@ %02d:%02d, %02d:%02d %@", NSLocalizedString(@"Start", comment: ""), startTimeInSec / 60, startTimeInSec % 60, leftTimeInSec / 60, leftTimeInSec % 60, NSLocalizedString(@"Remained", comment: "")];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelTime.text = timeString;
            self.audioPlayer.currentTime = CMTimeGetSeconds(self.selectedMusic.startTime);
        });
        
    }
}


#pragma mark - IBActions

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(id)sender {
    if (self.selectedMusic) {
        if ([self.controllerDelegate respondsToSelector:@selector(didSelectMusic:)]) {
            [self.controllerDelegate didSelectMusic:self.selectedMusic];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
