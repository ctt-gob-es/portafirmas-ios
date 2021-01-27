//
//  UserRolesService.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 03/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRolesService : NSObject
+ (UserRolesService *)instance;
- (void) getUserRoles:(void(^)(NSDictionary *content))success failure:(void(^)(NSError *error))failure;
@end
