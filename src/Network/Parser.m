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

@implementation Parser

NSString *loginKey = @"lgnrq";
NSString *contentKey = @"content";

NSString *errorKey = @"err";
NSString *cdKey = @"cd";
NSString *loginNotSupportedError = @"ERR-01";

- (void) parseAuthData: (NSData *)data success: (void(^)(NSString *token))success failure:(void(^)(NSError *))failure {
    
    XMLParser *parser = [[XMLParser alloc] init];
    
    __block NSString *pfUnivErrorDomain = PFUnivErrorDomain;
    
    [parser parseData:data success:^(id parsedData) {
        //NSLog(@"Data: %@", parsedData);
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
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

@end
