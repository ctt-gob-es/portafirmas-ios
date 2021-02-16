//
//  PushNotificationService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 3/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

@interface PushNotificationService : NSObject
@property (nonatomic, strong) Server *currentServer;
@property (nonatomic) BOOL isNotificationRequired;

+ (PushNotificationService *)instance;

- (void) initializePushNotificationsService: (BOOL) optionTappedByUser;
- (void) updateTokenOfPushNotificationsService: (NSString *) deviceToken;
- (void) unsubscribe;
- (BOOL) isNotificationEnabledOnSystem;
- (BOOL) hasUserAllowNotifications;
- (void) resetNotificationRequired ;

@end



