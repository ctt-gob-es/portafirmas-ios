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
#import "CookieTools.h"
#import "PushNotificationService.h"
#import "Server.h"

@interface LoginService ()
@property (nonatomic, strong) NSString *currentSignToken;
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

- (void) authID {
    
    [LoginNetwork loginProcess:^(NSString *token) {
        NSString *decodedToken = [self decodeToken:token];
        NSString *signToken = [self signToken:decodedToken];
        NSString *certificate = [self certificateInBase64];
		[LoginNetwork validateLogin:certificate withSignedToken:signToken success:nil failure:nil];
    } failure:nil];
}
    
- (void) loginWithCertificate:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    [LoginNetwork loginProcess:^(NSString *token) {
        self.serverSupportLogin = YES;
        NSString *decodedToken = [self decodeToken:token];
        self.currentSignToken = [self signToken:decodedToken];
        NSString *certificate = [self certificateInBase64];
        
        [LoginNetwork validateLogin:certificate withSignedToken:self.currentSignToken success:^{
           dispatch_async(dispatch_get_main_queue(), ^{
				[SVProgressHUD dismiss];
			});
            if ([PushNotificationService instance].currentServer.userNotificationPermisionState) {
                [[PushNotificationService instance] initializePushNotificationsService:false];
            }
            success();
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
				[SVProgressHUD dismiss];
			});
            self.serverSupportLogin = NO;
			NSLog(@"Error: %@", error);
            failure(error);
        }];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        
        //Check if is old server
        if (error != nil && error.code == PFLoginNotSupported) {
            self.serverSupportLogin = NO;
        }
        failure(error);
    }];
    
}

- (void) logout:(void(^)(void))success failure:(void(^)(NSError *error))failure {
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    
    [LoginNetwork logout:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        self.serverSupportLogin = false;
        self.currentSignToken = @"";
        [CookieTools removeJSessionIDCookies];
        success();
    } failure:^(NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        self.serverSupportLogin = false;
        self.currentSignToken = @"";
        [CookieTools removeJSessionIDCookies];
        failure(error);
    }];
}

- (NSString *) signToken: (NSString *) token {
    
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA256:tokenData];
    NSString *tokenSigned = [NSString stringWithFormat: @"%@",[result base64EncodedString]];
    
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
