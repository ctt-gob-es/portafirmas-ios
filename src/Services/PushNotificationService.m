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

+ (PushNotificationService *)instance {
    static PushNotificationService *pushNotificationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushNotificationService = [[self alloc] init];
    });
    return pushNotificationService;
}

- (void) initializePushNotificationsService {
    if (IOS_NEWER_OR_EQUAL_TO_10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

@end
