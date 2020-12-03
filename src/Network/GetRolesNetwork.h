//
//  GetRolesNetwork.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 02/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetRolesNetwork : NSObject

- (void) getRoles:(void(^)(void))success failure:(void(^)(NSError *error))failure;

@end
