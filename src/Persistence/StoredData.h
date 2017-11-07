//
//  StoredData.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 7/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, BoolType) {
    FalseValue = 0,
    TrueValue = 1
};

@interface StoredData : NSObject

@property (strong, nonatomic) NSString *devicePushNotificationToken;
@property (nonatomic) BoolType userNotificationPermisionState;

- (void) saveData;
- (void) loadData;
- (void) updateDeviceToken: (NSString *)deviceToken;
- (void) updateUserNotificationState: (BoolType)userNotificationPermisionState;
- (void) updateData: (NSString *) deviceToken notificationPermisionState:(BoolType) userNotificationPermisionState;
- (BOOL) getUserNotificationPermissionIsEnabled;

@end
