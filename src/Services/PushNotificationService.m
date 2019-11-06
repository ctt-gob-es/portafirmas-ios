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
                    [self createServerWithEmptyToken];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
                    });
                    
                    if (optionTappedByUser) {
                         [[ErrorService instance] showNotAllowNotifications];
                    }
                    
                    self.isNotificationRequired = false;
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
            [self createServerWithEmptyToken];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
            });
            self.isNotificationRequired = false;
        }
    }];
}

- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken {
    
    if (![self.currentServer.token isEqualToString:deviceToken] && self.isNotificationRequired) {
        [self updateToken:deviceToken];
    } else {
        self.isNotificationRequired = false;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    }
}

- (void) updateToken: (NSString *) token {
    
    NSString *IDVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [SVProgressHUD show];
    [PushNotificationNetwork subscribeDevice:IDVendor withToken:token success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        self.isNotificationRequired = false;
        NSString *certificate = [[LoginService instance] certificateInBase64];
        [[ServerManager instance] addServer:SERVER_URL withToken:token withCertificate:certificate andUserNotificationPermisionState:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    } failure:^(NSError *error) {
        self.isNotificationRequired = false;
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
    }];
}

#pragma mark - Utils

- (void) resetNotificationRequired {
    self.isNotificationRequired = false;
}

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
