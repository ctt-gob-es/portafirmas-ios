//
//  LoginNetwork.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginNetwork : NSObject

+ (void) loginProcess:(void(^)())success failure:(void(^)(NSError *))failure;

@end
