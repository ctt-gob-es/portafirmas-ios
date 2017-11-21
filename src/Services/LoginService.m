//
//  LoginService.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "LoginService.h"
#import "LoginNetwork.h"

@interface LoginService ()
@property (nonatomic, strong) StoredData* storedData;
@end

@implementation LoginService
    
+ (LoginService *)instance {
    static LoginService *loginService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginService = [[self alloc] init];
    });
    return loginService;
}

- (StoredData *)storedData {
    if (!_storedData) {
        _storedData = [[StoredData alloc] init];
        [_storedData loadData];
    }
    return _storedData;
}

- (void) authID {
    
    [LoginNetwork loginProcess:^(NSString *token) {
        NSLog(@"Token = %@", token);
    } failure:^(NSError *error) {
        DDLogError(@"Error starting login process");
        DDLogError(@"Error: %@", error);
    }];
    
    
}
@end
