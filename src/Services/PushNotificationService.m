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
#import "ServerManager.h"
#import "ErrorService.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@interface PushNotificationService ()

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
        
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    [self regiterForRemoteNotifications];
                    break;
                case UNAuthorizationStatusDenied:
                    [[ErrorService instance] showNotAllowNotifications];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
                    break;
                default:
                    [self regiterForRemoteNotifications];
                    break;
            }
        }];
        
    } else {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void) regiterForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        } else {
            NSString *certificate = [[LoginService instance] certificateInBase64];
            [[ServerManager instance] addServer:SERVER_URL withToken:@"" withCertificate:certificate andUserNotificationPermisionState:false];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
        }
    }];
}

- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken {
    
    if (![self.currentServer.token isEqualToString:deviceToken]) {
        [self updateToken:deviceToken];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    }
}

- (void) updateToken: (NSString *) token {
    
    NSString *IDVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [PushNotificationNetwork subscribeDevice:IDVendor withToken:token success:^{
        [SVProgressHUD dismiss];
        NSString *certificate = [[LoginService instance] certificateInBase64];
        [[ServerManager instance] addServer:SERVER_URL withToken:token withCertificate:certificate andUserNotificationPermisionState:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
        DDLogDebug(@"Push Notification Token Registered");
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
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
