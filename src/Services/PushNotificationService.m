//
//  PushNotificationService.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 3/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "PushNotificationService.h"
#import <UserNotifications/UserNotifications.h>
#import "PushNotificationNetwork.h"
#import "LoginService.h"
#import "Server.h"
#import "ServerManager.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@interface PushNotificationService ()
@property (nonatomic, strong) Server *currentServer;
@end

@implementation PushNotificationService

+ (PushNotificationService *)instance {
    static PushNotificationService *pushNotificationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushNotificationService = [[self alloc] init];
    });
    return pushNotificationService;
}

- (Server *) currentServer {
    NSString *certificate = [[LoginService instance] certificateInBase64];
    _currentServer = [[ServerManager instance] serverWithUrl:SERVER_URL andCertificate:certificate];
    return _currentServer;
}

- (void) initializePushNotificationsService {
    if (IOS_NEWER_OR_EQUAL_TO_10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            } else {
                NSString *certificate = [[LoginService instance] certificateInBase64];
                [[ServerManager instance] addServer:SERVER_URL withToken:@"" withCertificate:certificate andUserNotificationPermisionState:false];
            }
        }];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken {
    
    if (![self.currentServer.token isEqualToString:deviceToken]) {
        [self updateToken:deviceToken];
    }
}

- (void) updateToken: (NSString *) token {
    
    NSString *IDVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [PushNotificationNetwork subscribeDevice:IDVendor withToken:token success:^{
        NSString *certificate = [[LoginService instance] certificateInBase64];
        [[ServerManager instance] addServer:SERVER_URL withToken:token withCertificate:certificate andUserNotificationPermisionState:true];
        DDLogDebug(@"Push Notification Token Registered");
    } failure:^(NSError *error) {
        DDLogError(@"Error subscribing token");
        DDLogError(@"Error: %@", error);
    }];
}

#pragma mark - Utils

- (BOOL) isSubscriptionEnabled {
    if ([self isNotificationEnabledOnSystem] && [self isNotificationEnabledLocally]) {
        return true;
    }
    
    return false;
}

- (BOOL) isNotificationEnabledOnSystem {
    return [UIApplication.sharedApplication isRegisteredForRemoteNotifications];
}

- (BOOL) isNotificationEnabledLocally {
    return _currentServer.userNotificationPermisionState;
}

@end
