//
//  VideoViewController.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "MusicViewController.h"
#import "MusicItem.h"
#import "VideoGenerator.h"

@interface VideoViewController () < MusicViewControllerDelegate >

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) MusicItem *musicItem;

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerViewController *playerController;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerController = [[AVPlayerViewController alloc] init];
    
    self.avPlayer = [[AVPlayer alloc] initWithURL:self.videoURL];
    self.playerController.player = self.avPlayer;
    [self addChildViewController:self.playerController];
    [self.playerController.view setFrame:CGRectMake(24, 24, self.videoView.bounds.size.width - 48, self.videoView.bounds.size.height - 48)];
    [self.videoView addSubview:self.playerController.view];
    self.playerController.showsPlaybackControls = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.playerController.view setFrame:CGRectMake(24, 24, self.videoView.bounds.size.width - 48, self.videoView.bounds.size.height - 48)];
    [self.avPlayer play];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - MusicViewControllerDelegate

- (void)didSelectMusic:(MusicItem *)music {
    [self.avPlayer pause];
    self.musicItem = music;
    
    [VideoGenerator addMusicToVideo:self.videoURL withAudioURL:self.musicItem.fileURL musicStartTime:self.musicItem.startTime withCompletionBlock:^(NSURL * _Nonnull finalURL) {
        self.videoURL = finalURL;
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:finalURL];
        [self.avPlayer replaceCurrentItemWithPlayerItem:item];
        [self.avPlayer play];
    }];
}


#pragma mark - IBActions

- (IBAction)actionBack:(id)sender {
    [self.avPlayer pause];
    self.avPlayer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAddMusic:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MusicViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MusicViewController"];
    vc.controllerDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShare:(id)sender {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:self.videoURL] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
