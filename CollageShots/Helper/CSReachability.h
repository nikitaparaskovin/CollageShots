//
//  CSReachability.h
//  CollageShots
//
//  Created by HKC on 8/22/19.
//  Copyright © 2019 HKC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

extern NSString *kReachabilityChangedNotification;

@interface CSReachability : NSObject

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;
+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;
- (void)stopNotifier;
- (NetworkStatus)currentReachabilityStatus;
- (BOOL)connectionRequired;

@end

NS_ASSUME_NONNULL_END
