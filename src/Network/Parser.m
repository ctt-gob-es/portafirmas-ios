//
//  Parser.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "Parser.h"
#import "XMLParser.h"

@implementation Parser

NSString *loginKey = @"lgnrq";
NSString *contentKey = @"content";

- (void) parseAuthData: (NSData *)data success: (void(^)(NSString *token))success failure:(void(^)(NSError *))failure {
    
    XMLParser *parser = [[XMLParser alloc] init];
    
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
        }
        failure(nil);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

@end
