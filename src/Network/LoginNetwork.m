//
//  LoginNetwork.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "LoginNetwork.h"
#import "NSData+Base64.h"
#import "Parser.h"
#import "NSString+XMLSafe.h"
#import "userDNIManager.h"
#import "LoginService.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation LoginNetwork

- (void) loginProcess:(void(^)(NSString *token))success failure:(void(^)(NSError *error))failure {
    
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
	NSInteger operation = 10;
	NSString *dataString = @"<lgnrq />";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
	NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
                      (unsigned long)operation, datParameter, [data base64EncodedString]];
	
	if ([[LoginService instance] sessionId]){
		params = [NSString stringWithFormat:@"%@%@", params , [NSString stringWithFormat:@"&ssid=%@", [[LoginService instance] sessionId]]];
	}
	
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:kPFRequestTimeoutInterval];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            Parser *parser = [Parser new];
            
            [parser parseAuthData:data success:^(NSString *token) {
                success(token);
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    }] resume];
}

- (void) loginWithRemoteCertificates:(void(^)(NSDictionary *content))success failure:(void(^)(NSError *error))failure {
	
	NSString *opParameter = @"op";
	NSString *datParameter = @"dat";
	NSString *baseURL = SERVER_URL;
	NSInteger operation = 14;
	NSString *dataString = @"<lgnrq />";
	NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
						(unsigned long)operation, datParameter, [data base64EncodedString]];
	
	NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:baseURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	[request setHTTPShouldHandleCookies:YES];
	[request setTimeoutInterval:kPFRequestTimeoutInterval];
	
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			failure(error);
		} else  {
			NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			Parser *parser = [Parser new];
			[parser parseAuthWithRemoteCertificates:data success:^(NSDictionary *content) {
				success(content);
				
				
				//Token is the url
			} failure:^(NSError *error) {
				failure(error);
			}];
		}
	}] resume];
}

- (void) validateLogin:(NSString*)certificate withSignedToken:(NSString*)tokenSigned success: (void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 11;
	NSMutableString *dataString = [[NSMutableString alloc] initWithString:@"<rqtvl>"];
	if (certificate){
		NSString *certificateString = [NSString stringWithFormat:@"<cert>%@</cert>", certificate];
		[dataString appendString:certificateString];
	}
	NSString *tokenSignedString = [NSString stringWithFormat:@"<pkcs1>%@</pkcs1></rqtvl>", tokenSigned];
	[dataString appendString:tokenSignedString];
    NSString *xmlSafeString = [dataString xmlSafeString];
    NSData *data = [xmlSafeString  dataUsingEncoding:NSUTF8StringEncoding];
    NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
                        (unsigned long)operation,datParameter, [data base64EncodedString]];

    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:kPFRequestTimeoutInterval];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            Parser *parser = [Parser new];
            
            [parser parseValidateData:data success:^(BOOL isValid) {
                if (isValid) {
                    success();
                } else {
                   failure(nil);
                }
                
            } failure:^(NSError *error) {
                failure(error);
            }];
            
        }
    }] resume];
}

- (void) logout:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 12;
    NSString *dataString = @"<lgorq/>";
    
    NSString *xmlSafeString = [dataString xmlSafeString];
    
    NSData *data = [xmlSafeString  dataUsingEncoding:NSUTF8StringEncoding];
    NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
                        (unsigned long)operation,datParameter, [data base64EncodedString]];
    
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:kPFRequestTimeoutInterval];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            success();
            [userDNIManager deleteUserDNI];
        }
    }] resume];
}
@end
