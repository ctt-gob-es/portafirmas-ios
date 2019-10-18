//
//  NotificationHandler.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 29/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "NotificationHandler.h"
#import "Notification.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation NotificationHandler

+ (BOOL) isNotificationForUserLogged: (NSDictionary *)userInfo {
    
    Notification *notification = [[Notification alloc] initWithUserInfo:userInfo];
    
    if (notification != nil) {
        if ([[NotificationHandler extractServerUrlOfBody:notification.alertBody] isEqualToString:SERVER_URL]) {
            return true;
        }
    }
    
    return false;
}

+ (NSString *) extractServerUrlOfBody: (NSString *) body {
    NSString *separator = @"$$";
    NSArray *items = [body componentsSeparatedByString:separator];
    if (items.count > 0) {
        return items.firstObject;
    }
    return @"";
}

@end
