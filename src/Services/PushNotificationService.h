//
//  PushNotificationService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 3/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationService : NSObject

+ (PushNotificationService *)instance;

- (void) initializePushNotificationsService;

@end



