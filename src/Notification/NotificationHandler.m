//
//  NotificationHandler.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 29/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "NotificationHandler.h"
#import "Notification.h"
#import "NSData+Base64.h"
#import "Base64Utils.h"
#import "CertificateUtils.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]
#define SERVER_DNI (NSString *)[[NSUserDefaults standardUserDefaults] stringForKey:kPFUserDefaultsKeyDNI]

@implementation NotificationHandler

+ (BOOL) isNotificationForUserLogged: (NSDictionary *)userInfo {
    
    Notification *notification = [[Notification alloc] initWithUserInfo:userInfo];
    
    if (notification != nil) {
        if ([[NotificationHandler extractServerUrlOfBody:notification.alertBody] isEqualToString:SERVER_URL])
			// TODO: INCLUDE HERE THE EXTRA COMPROBATION FOR DNI WHEN PUSH NOTIFICATIONS ARE ENABLED.
//            && [[NotificationHandler extractServerDNIOfBody:notification.alertBody] isEqualToString:SERVER_DNI])
			// TODO: Change previous comparison for a hash DNI comparison
//			&& [[NotificationHandler extractHashDNIOfBody: notification.alertBody] isEqualToString: [self hashWithSHA1AndBase64:SERVER_DNI]])
			
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

+ (NSString *) extractHashDNIOfBody: (NSString *) body {
	// TODO: Create the logic to obtain hash DNI from notification body.
	
	// Use a hardcoded hash DNI and extracted from 11111111H :
    return @"abe9025c434334c053adb108b83ff2e6f1dd3993";
}

+ (NSString *) hashWithSHA1AndBase64: (NSString *) string {
	// With the original string
	NSString *originalString = string;
	NSData *data = [originalString dataUsingEncoding:NSUTF8StringEncoding];
	// Apply the hash
	NSData *hashMessage = [CertificateUtils getHashBytesSHA1:data] ;
	NSLog(@"hashMessage: %@", hashMessage);
	// Encode it in Base64
	NSString *hashAndBase64 = [Base64Utils base64EncodeData: hashMessage];
	NSLog(@"hashAndBase64: %@", hashAndBase64);
	return hashAndBase64;
}

@end
