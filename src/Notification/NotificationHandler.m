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
#define SERVER_DNI (NSString *)[[NSUserDefaults standardUserDefaults] stringForKey:kPFUserDefaultsKeyDNI]

@implementation NotificationHandler

+ (BOOL) isNotificationForUserLogged: (NSDictionary *)userInfo {
    
    Notification *notification = [[Notification alloc] initWithUserInfo:userInfo];
    
    if (notification != nil) {
        if ([[NotificationHandler extractServerUrlOfBody:notification.alertBody] isEqualToString:SERVER_URL])
			// TODO: INCLUDE HERE THE EXTRA COMPROBATION FOR DNI WHEN PUSH NOTIFICATIONS ARE ENABLED.
//            && [[NotificationHandler extractServerDNIOfBody:notification.alertBody] isEqualToString:SERVER_DNI])
		{
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

+(NSString *) extractServerDNIOfBody: (NSString *) body {
    //Create the logic when we can test with notifications.
    return @"11111111H";
}

@end
