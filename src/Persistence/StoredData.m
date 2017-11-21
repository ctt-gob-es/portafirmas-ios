//
//  StoredData.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 7/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "StoredData.h"
#import "UICKeyChainStore.h"

@implementation StoredData

static NSString *const appService = @"es.gob.afirma.Portafirmas";
static NSString *const devicePushNotificationTokenKeychain = @"device_push_notification_token_keychain";
static NSString *const userNotificationPermisionStateKeychain = @"userNotificationIsEnableInKeychain";

static NSString *const trueValue = @"TrueValue";
static NSString *const falseValue = @"FalseValue";

@synthesize devicePushNotificationToken = _devicePushNotificationToken;
@synthesize userNotificationPermisionState = _userNotificationPermisionState;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _devicePushNotificationToken = @"";
        _userNotificationPermisionState = TrueValue;
    }
    return self;
}


- (NSString *) getUserNotificationPermisionStateStringValue: (BoolType) type {
    if (type == FalseValue) {
        return falseValue;
    }
    return trueValue;
}

- (BoolType) getUserNotificationPermisionStateBoolValue: (NSString *)name {
    if ([name isEqualToString:falseValue]) {
        return FalseValue;
    }
    return TrueValue;
}

- (void) saveData {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:appService];
    keychain[devicePushNotificationTokenKeychain] = self.devicePushNotificationToken;
    keychain[userNotificationPermisionStateKeychain] = [self getUserNotificationPermisionStateStringValue:self.userNotificationPermisionState];
}

- (BOOL) getUserNotificationPermissionIsEnabled {
    if (self.userNotificationPermisionState == FalseValue) {
        return false;
    }
     return true;
}

- (void) loadData {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:appService];
    self.devicePushNotificationToken = keychain[devicePushNotificationTokenKeychain];
    self.userNotificationPermisionState = [self getUserNotificationPermisionStateBoolValue:keychain[userNotificationPermisionStateKeychain]];
}

- (void) updateDeviceToken: (NSString *)deviceToken {
    self.devicePushNotificationToken = deviceToken;
    [self saveData];
}

- (void) updateUserNotificationState: (BoolType)userNotificationPermisionState {
    self.userNotificationPermisionState = userNotificationPermisionState;
    [self saveData];
}

- (void) updateData: (NSString *) deviceToken notificationPermisionState:(BoolType) userNotificationPermisionState {
    self.devicePushNotificationToken = deviceToken;
    self.userNotificationPermisionState = userNotificationPermisionState;
    [self saveData];
}
@end
