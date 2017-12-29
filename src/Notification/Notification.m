//
//  Notification.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 29/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id) initWithUserInfo: (NSDictionary *) userInfo {
    self = [super init];
    if (self) {
        NSString *aps = @"aps";
        NSString *alert = @"alert";
        NSString *body = @"body";
        NSString *title = @"title";
        
        NSDictionary *apsObject = [userInfo objectForKey:aps];
        NSDictionary *alertObject = [apsObject objectForKey:alert];
        
        self.alertBody = [alertObject objectForKey:body];
        self.alertTitle = [alertObject objectForKey:title];
    }
    return self;
}

@end
