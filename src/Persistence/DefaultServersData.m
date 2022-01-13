//
//  DefaultServersData.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 11/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "DefaultServersData.h"
#import "DefaultDataConstants.h"

@implementation DefaultServersData

+ (void) createDefaultServersIsNotExist {
    if ([DefaultServersData isFirstInitToIncludeDefaultServers]) {
        [DefaultServersData createDefaultServers];
    }
}

+ (BOOL) isFirstInitToIncludeDefaultServers {
    NSString *firstInitToIncludeDefaultServers = @"hasLaunchOnceToIncludeDefaultServers";
    
    if ((![[NSUserDefaults standardUserDefaults] boolForKey:firstInitToIncludeDefaultServers]) || !([[NSUserDefaults standardUserDefaults] arrayForKey:@"serversArray"].count > 0))
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:firstInitToIncludeDefaultServers];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

+ (void) createDefaultServers {

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultsKeys = standardUserDefaults.dictionaryRepresentation.allKeys;
    NSMutableArray *serversArray = [[defaultsKeys containsObject:kPFUserDefaultsKeyServersArray] ? [standardUserDefaults arrayForKey:kPFUserDefaultsKeyServersArray] : @[] mutableCopy];
    
    [serversArray addObject:@{kPFUserDefaultsKeyAlias:serverAlias1, kPFUserDefaultsKeyURL:serverURL1}];
    [serversArray addObject:@{kPFUserDefaultsKeyAlias:serverAlias2, kPFUserDefaultsKeyURL:serverURL2}];
    
    [[NSUserDefaults standardUserDefaults] setObject:serversArray forKey:kPFUserDefaultsKeyServersArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
