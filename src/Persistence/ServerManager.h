//
//  ServerManager.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 15/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"
#import <Realm/Realm.h>

@interface ServerManager : NSObject
@property (nonatomic, strong) RLMRealm *realm;

+ (ServerManager *)instance;
- (void) addServer: (NSString *) url withToken: (NSString *) token withCertificate: (NSString *)certificate andUserNotificationPermisionState: (BOOL) notificationState;
- (Server *) serverWithUrl: (NSString *) url andCertificate: (NSString *)certificate;

@end
