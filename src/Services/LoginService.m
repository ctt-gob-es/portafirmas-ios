//
//  LoginService.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "LoginService.h"
#import "LoginNetwork.h"

#import "CertificateUtils.h"
#import "Base64Utils.h"
#import "NSData+Base64.h"

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
        NSString *signToken = [self signToken:token];
        NSLog(@"Sign Token = %@", signToken);
        
        
        
    } failure:^(NSError *error) {
        DDLogError(@"Error starting login process");
        DDLogError(@"Error: %@", error);
    }];
}

- (NSString *) signToken: (NSString *) token {
    
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA256:tokenData];
    
    NSString *tokenSigned = [NSString stringWithFormat: @"%@",[result base64EncodedString]];
    return tokenSigned;
}
@end
