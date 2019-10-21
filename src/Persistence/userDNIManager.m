//
//  userDNIManager.m
//  PortaFirmasUniv
//
//  Created by Sergio PH on 29/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "userDNIManager.h"

@implementation userDNIManager

+ (void) setUserDNI:(NSString *)DNI
{
    [[NSUserDefaults standardUserDefaults] setObject:DNI forKey:kPFUserDefaultsKeyDNI];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) deleteUserDNI{
    [self setUserDNI:@""];
}

@end
