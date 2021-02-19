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
#import "NSData+Base64.h"
#import "PFError.h"
#import "CookieTools.h"
#import "PushNotificationService.h"
#import "Server.h"
#import "GlobalConstants.h"

@interface LoginService ()
@property (nonatomic, strong) NSString *currentSignToken;
@end

@implementation LoginService

static NSString *const kUrl = @"url";
static NSString *const kSessionId = @"sessionId";
    
+ (LoginService *)instance {
    static LoginService *loginService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginService = [[self alloc] init];
    });
    return loginService;
}

- (void) authID {
	
	LoginNetwork *loginNetwork = [LoginNetwork new];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    [loginNetwork loginProcess:^(NSString *token) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        NSString *decodedToken = [self decodeToken:token];
        NSString *signToken = [self signToken:decodedToken];
        NSString *certificate = [self certificateInBase64];
		[loginNetwork validateLogin:certificate withSignedToken:signToken success:nil failure:nil];
	} failure:^(NSError *error){
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	}
	 ];
}
    
- (void)extracted:(void (^)(NSError *))failure success:(void (^)(void))success {
	
	LoginNetwork *loginNetwork = [LoginNetwork new];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
	
	[loginNetwork loginProcess:^(NSString *token) {
		self.serverSupportLogin = YES;
		NSString *decodedToken = [self decodeToken:token];
		self.currentSignToken = [self signToken:decodedToken];
		NSString *certificate = [self certificateInBase64];
		
		[loginNetwork validateLogin:certificate withSignedToken:self.currentSignToken success:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[SVProgressHUD dismiss];
			});
			success();
		} failure:^(NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[SVProgressHUD dismiss];
			});
			self.serverSupportLogin = NO;
			self.remoteCertificateLoginOK = NO;
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
		self.remoteCertificateLoginOK = NO;
		failure(error);
	}];
}

- (void) loginWithRemoteCertificates:(void(^)(void))success failure:(void(^)(NSError *error))failure {
	LoginNetwork *loginNetwork = [LoginNetwork new];
	[loginNetwork loginWithRemoteCertificates:^(NSDictionary *content) {
		[self setRemoteCertificatesParameters: content];
		self.remoteCertificateLoginOK = YES;
		success();
	} failure:^(NSError *error) {
		[SVProgressHUD dismiss];
		//Check if is old server
		if (error != nil && error.code == PFLoginNotSupported) {
			self.serverSupportLogin = NO;
		}
		self.remoteCertificateLoginOK = NO;
		failure(error);
	}];
}

- (void) loginWithCertificate:(void(^)(void))success failure:(void(^)(NSError *error))failure {
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
	[self extracted:failure success:success];
}

- (void) logout:(void(^)(void))success failure:(void(^)(NSError *error))failure {
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});

	LoginNetwork *loginNetwork = [LoginNetwork new];

	[loginNetwork logout:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [self resetValuesAfterLogout];
        success();
    } failure:^(NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [self resetValuesAfterLogout];
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
	NSData *data = [[NSData alloc] initWithBase64EncodedString:token options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *) certificateInBase64 {
    NSData *certificateData = [CertificateUtils sharedWrapper].publicKeyBits;
	return [certificateData base64EncodedString];
}

- (void) setRemoteCertificatesParameters: (NSDictionary *) content {
	if([content objectForKey:kUrl]){
		self.urlForRemoteCertificates = [[content objectForKey:kUrl] objectForKey: kContentKey];
	}
	if([content objectForKey:kSessionId]){
		self.sessionId = [[content objectForKey:kSessionId] objectForKey: kContentKey];
	}
}

- (void) resetValuesAfterLogout {
    self.serverSupportLogin = NO;
    self.remoteCertificateLoginOK = NO;
    self.currentSignToken = @"";
    [CookieTools removeJSessionIDCookies];
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey:kPFUserDefaultsKeyUserConfigurationCompatible];
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey:kPFUserDefaultsKeyPortafirmasNotificationsActivated];
    [[NSUserDefaults standardUserDefaults] setBool: NO  forKey:kPFUserDefaultsKeyUserNotificationsActivated];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyUserRoles];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyUserRoleSelected];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyPushNotificationsServiceToken];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyUserSelectionFilterSubject];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyUserSelectionFilterApp];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyUserSelectionFilterType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
