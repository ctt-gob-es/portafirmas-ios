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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isNotificationRequired = false;
    }
    return self;
}

- (Server *) currentServer {
    NSString *certificate = [[LoginService instance] certificateInBase64];
    _currentServer = [[ServerManager instance] serverWithUrl:SERVER_URL andCertificate:certificate];
    return _currentServer;
}

- (void) initializePushNotificationsService: (BOOL) optionTappedByUser {
    
    self.isNotificationRequired = true;
    
    if (IOS_NEWER_OR_EQUAL_TO_10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    [self registerForRemoteNotificationsSinceiOS10];
                    break;
                case UNAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (optionTappedByUser) {
                             [[ErrorService instance] showNotAllowNotifications];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyPushNotificationsServiceToken];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
                    });
                    break;
                }
                default:
                    [self registerForRemoteNotificationsSinceiOS10];
                    break;
            }
        }];
        
    } else {
        
        if ([self isFirstInitWithPushNotificationPopUpAnswered]) {
            
            [self registerForRemoteNotificationsUntiliOS10];
            
            [self createServerWithEmptyToken];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
            });
            
        } else {
            if ([self isNotificationEnabledOnSystem]) {
                [self registerForRemoteNotificationsUntiliOS10];
            } else {
                
                if (optionTappedByUser) {
                   [[ErrorService instance] showNotAllowNotifications];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
                });
            }
        }
    }
}

- (void) createServerWithEmptyToken {
    NSString *certificate = [[LoginService instance] certificateInBase64];
    [[ServerManager instance] addServer:SERVER_URL withToken:@"" withCertificate:certificate andUserNotificationPermisionState:false];
}

- (void) registerForRemoteNotificationsUntiliOS10 {
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void) registerForRemoteNotificationsSinceiOS10 {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
            });
        }
    }];
}

- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken {
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyPushNotificationsServiceToken] isEqualToString: deviceToken]) {
        [self updateTokenAndSubscribe:deviceToken];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    }
}

- (void) updateTokenAndSubscribe: (NSString *) token {
    NSString *IDVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    [PushNotificationNetwork subscribeDevice:IDVendor withToken:token success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [[NSUserDefaults standardUserDefaults] setObject:token forKey: kPFUserDefaultsKeyPushNotificationsServiceToken];
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:kPFUserDefaultsKeyUserNotificationsActivated];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyPushNotificationsServiceToken];
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey:kPFUserDefaultsKeyUserNotificationsActivated];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[ErrorService instance] showAlertViewWithTitle:@"Alert_View_Can_Not_Subscribe_Notifications_Title".localized andMessage:[error localizedDescription]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    }];
}

#pragma mark - Utils

- (BOOL) isNotificationEnabledOnSystem {
    return [UIApplication.sharedApplication isRegisteredForRemoteNotifications];
}

- (BOOL) isFirstInitWithPushNotificationPopUpAnswered {
    NSString *firstInitWithPushNotificationPopUpAnswered = @"hasUserAnswerToPushNotificationPopUp";
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:firstInitWithPushNotificationPopUpAnswered])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:firstInitWithPushNotificationPopUpAnswered];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

- (BOOL) hasUserAllowNotifications {
    
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        return false;
    }
    else {
        return true;
    }
}

@end
