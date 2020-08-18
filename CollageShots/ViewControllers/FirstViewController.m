//
//  FirstViewController.m
//  CollageShots
//
//  Created by HKC on 8/21/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import "FirstViewController.h"
#import "CSReachability.h"
#import "CollagesViewController.h"
#import "AppDelegate.h"
@import OneSignal;

@interface FirstViewController ()

@property (nonatomic) CSReachability *internetReachability;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self goToFirstView];
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)goToFirstView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CollagesViewController *vc = (CollagesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CollagesViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.navigationBar.hidden = YES;
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    delegate.window.rootViewController = navigationController;
}

@end
