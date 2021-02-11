//
//  Parser.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "Parser.h"
#import "XMLParser.h"
#import "PFError.h"
#import "userDNIManager.h"

@implementation Parser

NSString *loginKey = @"lgnrq";
NSString *contentKey = @"content";
NSString *errorKey = @"err";
NSString *cdKey = @"cd";
NSString *loginNotSupportedError = @"ERR-01";

NSString *logValidateKey = @"vllgnrq";
NSString *logValidateErrorKey = @"er";
NSString *logValidateOkKey = @"ok";
NSString *logValidateDNI = @"dni";

NSString *subscriptionKey = @"reg";
NSString *subscriptionValidateOkKey = @"ok";

- (void) parseAuthData: (NSData *)data success: (void(^)(NSString *token))success failure:(void(^)(NSError *))failure {
    XMLParser *parser = [[XMLParser alloc] init];
    __block NSString *pfUnivErrorDomain = PFUnivErrorDomain;
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            NSDictionary *loginDict = [parsedDataDict objectForKey:loginKey];
            if (loginDict != nil) {
                NSString *content = [loginDict objectForKey:contentKey];
                if (content != nil) {
                    success(content);
                    return;
                }
            }
            NSDictionary *errorDict = [parsedDataDict objectForKey:errorKey];
            if (errorDict != nil) {
                NSString *errorValue = [errorDict objectForKey:cdKey];
                if ([errorValue isEqualToString:loginNotSupportedError]) {
                    NSError *customError = [NSError errorWithDomain:pfUnivErrorDomain code:PFLoginNotSupported userInfo:nil];
                    failure(customError);
                    return;
                }
            }
        }
        failure(nil);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) parseAuthWithRemoteCertificates: (NSData *)data success: (void(^)(NSDictionary *content))success failure:(void(^)(NSError *))failure {
    XMLParser *parser = [[XMLParser alloc] init];
    __block NSString *pfUnivErrorDomain = PFUnivErrorDomain;
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            NSDictionary *loginDict = [parsedDataDict objectForKey:loginKey];
            if (loginDict != nil) {
                success(loginDict);
                return;
            }
            NSDictionary *errorDict = [parsedDataDict objectForKey:errorKey];
            if (errorDict != nil) {
                NSString *errorValue = [errorDict objectForKey:cdKey];
                if ([errorValue isEqualToString:loginNotSupportedError]) {
                    NSError *customError = [NSError errorWithDomain:pfUnivErrorDomain code:PFLoginNotSupported userInfo:nil];
                    failure(customError);
                    return;
                }
            }
        }
        failure(nil);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) parseFIRMeResponse: (NSData *)data success: (void(^)(NSDictionary *content))success failure:(void(^)(NSError *))failure {
    XMLParser *parser = [[XMLParser alloc] init];
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            success(parsedDataDict);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) parseValidateData: (NSData *)data success: (void(^)(BOOL isValid))success failure:(void(^)(NSError *))failure {
    
    XMLParser *parser = [[XMLParser alloc] init];
    
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            NSDictionary *validationDict = [parsedDataDict objectForKey:logValidateKey];
            
            if (validationDict != nil) {
                NSString *validation = [validationDict objectForKey:logValidateOkKey];
                
                BOOL isValid = false;
                
                if ([validation isEqualToString:@"true"]) {
                    isValid = true;
                    [userDNIManager setUserDNI:[validationDict objectForKey:logValidateDNI]];
                }
                
                success(isValid);
                return;
            }
        }
        
        failure(nil);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) parseValidateSubscription: (NSData *)data success: (void(^)(BOOL isValid))success failure:(void(^)(NSError *))failure {
    
    XMLParser *parser = [[XMLParser alloc] init];
    
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            NSDictionary *validationDict = [parsedDataDict objectForKey:subscriptionKey];
            NSDictionary *errorDict = [parsedDataDict objectForKey:errorKey];
            if (validationDict != nil) {
                NSString *validation = [validationDict objectForKey:subscriptionValidateOkKey];
                BOOL isValid = false;
                if ([validation isEqualToString:@"true"]) {
                    isValid = true;
                }
                success(isValid);
                return;
            } else if (errorDict != nil) {
                NSMutableString *errorCodeString = [errorDict objectForKey:cdKey];
                NSInteger errorCode = [errorCodeString substringFromIndex:[errorCodeString length] - 1].intValue;
                NSError *error = [NSError errorWithDomain:[errorDict objectForKey:contentKey] code:errorCode userInfo:errorDict];
                failure(error);
                return;
            }
        }
        failure(nil);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

-(void) parseUserRoles: (NSData *)data success: (void(^)(NSDictionary *content))success failure:(void(^)(NSError *))failure {
    XMLParser *parser = [[XMLParser alloc] init];
    [parser parseData:data success:^(id parsedData) {
        if (parsedData != nil) {
            NSDictionary *parsedDataDict = (NSDictionary *)parsedData;
            success(parsedDataDict);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
