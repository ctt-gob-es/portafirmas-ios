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
    
+ (LoginService *)instance;
- (void) authID;
- (void) loginWithCertificate:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void) logout:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (NSString *) certificateInBase64;

@end
