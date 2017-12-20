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
        self.realPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingString:@"/portafirmas.realm"];
    }
    return self;
}

- (void) addServer: (NSString *) url withToken: (NSString *) token withCertificate: (NSString *)certificate andUserNotificationPermisionState: (BOOL) notificationState {
    
    Server *server = [self serverWithUrl:url andCertificate:certificate];
    
    RLMRealm *realm = [RLMRealm realmWithURL:[NSURL URLWithString:self.realPath]];
    [realm beginWriteTransaction];
    
    if (!server.serverId) {
        int max = [[Server allObjectsInRealm:realm] maxOfProperty:@"serverId"];
        
        if (max) {
           server.serverId = max + 1;
        } else {
           server.serverId = 0;
        }
    }
    server.url = url;
    server.token = token;
    server.certificate = certificate;
    server.userNotificationPermisionState = notificationState;
  
    [realm addOrUpdateObject:server];
    [realm commitWriteTransaction];
    
}

- (Server *) serverWithUrl: (NSString *) url andCertificate: (NSString *)certificate {
    RLMRealm *realm = [RLMRealm realmWithURL:[NSURL URLWithString:self.realPath]];
    RLMResults *results = [Server objectsInRealm:realm where:@"(url like %@) AND (certificate like %@)", url, certificate];
    
    if (results.count > 0) {
        return results[0];
    }
    
    return [Server new];
}
@end
