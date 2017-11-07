//
//  PushNotificationService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 3/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoredData.h"

@interface PushNotificationService : NSObject

@property (nonatomic, strong) StoredData* storedData;

+ (PushNotificationService *)instance;

- (void) initializePushNotificationsService;

@end



