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
#import "PFError.h"

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
        NSString *decodedToken = [self decodeToken:token];
        NSString *signToken = [self signToken:decodedToken];
        NSLog(@"Sign Token = %@", signToken);
        NSString *certificate = [self certificateInBase64];
        
        [LoginNetwork validateLogin:certificate withSignedToken:signToken success:^{
            NSLog(@"Login validated");
        } failure:^(NSError *error) {
            DDLogError(@"Error starting login process");
            DDLogError(@"Error: %@", error);
        }];
    } failure:^(NSError *error) {
        DDLogError(@"Error starting login process");
        DDLogError(@"Error: %@", error);
    }];
}
    
- (void) loginWithCertificate:(void(^)())success failure:(void(^)(NSError *error))failure {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [LoginNetwork loginProcess:^(NSString *token) {
        self.serverSupportLogin = YES;
        NSLog(@"Token = %@", token);
        NSString *decodedToken = [self decodeToken:token];
        NSString *signToken = [self signToken:decodedToken];
        NSLog(@"Sign Token = %@", signToken);
        NSString *certificate = [self certificateInBase64];
        
        [LoginNetwork validateLogin:certificate withSignedToken:signToken success:^{
            [SVProgressHUD dismiss];
            NSLog(@"Login validated");
            success();
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            DDLogError(@"Error starting login process");
            DDLogError(@"Error: %@", error);
            self.serverSupportLogin = NO;
            failure(error);
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        DDLogError(@"Error starting login process");
        
        //Check if is old server
        if (error != nil && error.code == PFLoginNotSupported) {
            self.serverSupportLogin = NO;
            DDLogError(@"Error: %@", error);
        }
        failure(error);
    }];
    
}

- (NSString *) signToken: (NSString *) token {
    
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA256:tokenData];
    NSString *tokenSigned = [NSString stringWithFormat: @"%@",[result base64EncodedString]];
    
   // NSLog(@"Token signed: %@", tokenSigned);
   // NSLog(@"Token lenght: %ld", [tokenSigned length]);
    
    return tokenSigned;
}

- (NSString *) decodeToken: (NSString *) token {
    NSData *data = [Base64Utils base64DecodeString:token];
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *) certificateInBase64 {
    NSData *certificateData = [CertificateUtils sharedWrapper].publicKeyBits;
    return [Base64Utils base64EncodeData:certificateData];
}
@end
