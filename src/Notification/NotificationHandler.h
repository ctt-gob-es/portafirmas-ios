//
//  NotificationHandler.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 29/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationHandler : NSObject
+ (BOOL) isNotificationForUserLogged: (NSDictionary *)userInfo;
@end
