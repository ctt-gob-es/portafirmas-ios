//
//  PushNotificationService.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 3/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "PushNotificationService.h"
#import <UserNotifications/UserNotifications.h>

@implementation PushNotificationService

@synthesize storedData = _storedData;


+ (PushNotificationService *)instance {
    static PushNotificationService *pushNotificationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushNotificationService = [[self alloc] init];
    });
    return pushNotificationService;
}

- (StoredData *)storedData {
    if (!_storedData) {
        _storedData = [[StoredData alloc] init];
        [_storedData loadData];
    }
    return _storedData;
}

- (void) initializePushNotificationsService {
    
    if ([[self storedData] getUserNotificationPermissionIsEnabled]) {
        if (IOS_NEWER_OR_EQUAL_TO_10) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
                if(!error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                } else {
                    [[self storedData] updateUserNotificationState:FalseValue];
                }
            }];
        } else {
            UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }
}

- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken {
    
    if (![deviceToken isEqualToString: [[self storedData] devicePushNotificationToken]] &&  [[self storedData] getUserNotificationPermissionIsEnabled]) {
        
        //TODO: Call to the endpoint to send the new device token
        
        //When success:
        
        [[self storedData] updateData:deviceToken notificationPermisionState:TrueValue];
        DDLogDebug(@"Push Notification Token Registered");
    } else {
        DDLogDebug(@"Push Notification Token Not Registered because is registered");
    }
    
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
    if ([[[self storedData] devicePushNotificationToken] isEqualToString:@""]) {
        return false;
    }
    
    return true;
}

@end
