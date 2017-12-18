//
//  ServerManager.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 15/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "ServerManager.h"


@implementation ServerManager

+ (ServerManager *)instance {
    static ServerManager *serverManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverManager = [[self alloc] init];
    });
    return serverManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.realm = [RLMRealm defaultRealm];
    }
    return self;
}

- (void) addServer: (NSString *) url withToken: (NSString *) token withCertificate: (NSString *)certificate andUserNotificationPermisionState: (BOOL) notificationState {
    
    Server *server = [self serverWithUrl:url andCertificate:certificate];
    
    [_realm beginWriteTransaction];
    
    if (!server.url) {
        server.url = url;
    }

    server.token = token;
    server.certificate = certificate;
    server.userNotificationPermisionState = notificationState;
    
    [_realm addOrUpdateObject:server];
    [_realm commitWriteTransaction];
}

- (Server *) serverWithUrl: (NSString *) url andCertificate: (NSString *)certificate {
    
    RLMResults *results = [Server objectsInRealm:_realm where:@"(url like %@) AND (certificate like %@)", url, certificate];
    
    if (results.count > 0) {
        return results[0];
    }
    
    return [Server new];
}
@end
