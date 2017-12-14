//
//  CookieTools.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 5/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "CookieTools.h"

@implementation CookieTools

+ (NSDictionary *) JSessionID {
    NSString *jsessionCookie = @"JSESSIONID";
    NSHTTPCookie *cookieSession;
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
       /* NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);*/
        
        if ([cookie.name isEqualToString:jsessionCookie]) {
            cookieSession = cookie;
        }
    }
    
    NSDictionary *cookieDict;
    if (cookieSession != nil) {
        NSArray *cookieArray = [NSArray arrayWithObject:cookieSession];
        cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    }
    
    return cookieDict;
}

+ (void) removeJSessionIDCookies {
    NSString *jsessionCookie = @"JSESSIONID";
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieStorage cookies])
    {
        if ([cookie.name isEqualToString:jsessionCookie]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

@end
