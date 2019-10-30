//
//  LoginService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginService : NSObject

@property (nonatomic) BOOL serverSupportLogin;
@property (nonatomic, strong) NSString *urlForRemoteCertificates;

+ (LoginService *)instance;
- (void) authID;
- (void) loginWithCertificate:(void(^)())success failure:(void(^)(NSError *error))failure;
- (void) loginWithRemoteCertificates:(void(^)())success failure:(void(^)(NSError *error))failure;
- (void) logout:(void(^)())success failure:(void(^)(NSError *error))failure;
- (NSString *) certificateInBase64;

@end
