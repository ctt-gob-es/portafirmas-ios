//
//  UserRolesService.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 03/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import "UserRolesService.h"
#import "UserRolesNetwork.h"

@interface UserRolesService ()
@end

@implementation UserRolesService

+ (UserRolesService *)instance {
    static UserRolesService *userRolesService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userRolesService = [[self alloc] init];
    });
    return userRolesService;
}

- (void) getUserRoles:(void(^)(NSDictionary *content))success failure:(void(^)(NSError *error))failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    UserRolesNetwork *userRolesNetwork = [UserRolesNetwork new];
    [userRolesNetwork getUserRoles:^(NSDictionary *content) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            success(content);
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        failure(error);
    }];
}

@end
