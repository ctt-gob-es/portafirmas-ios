//
//  PushNotificationNetwork.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 8/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationNetwork : NSObject

+ (void) subscribeDevice:(NSString *)deviceID withToken: (NSString*)token success: (void(^)(void))success failure:(void(^)(NSError *error))failure;

+ (void) subscribeDevice:(BOOL)subscribe success: (void(^)(void))success failure:(void(^)(NSError *error))failure;

@end
