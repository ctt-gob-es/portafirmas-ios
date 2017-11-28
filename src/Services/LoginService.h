//
//  LoginService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoredData.h"

@interface LoginService : NSObject
    
+ (LoginService *)instance;
- (void) authID;
- (void) loginWithCertificate:(void(^)())success failure:(void(^)(NSError *error))failure;

@end
