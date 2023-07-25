//
//  GetRolesNetwork.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 02/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import "CookieTools.h"
#import "UserRolesNetwork.h"
#import "LoginService.h"
#import "NSData+Base64.h"
#import "Parser.h"
#import "UserRolesService.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation UserRolesNetwork

- (void) getUserRoles:(void(^)(NSDictionary *content))success failure:(void(^)(NSError *error))failure {
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 18;
    NSString *dataString = [NSString stringWithFormat:@"<rqsrcnfg/>"];
    
    NSData *data = [dataString  dataUsingEncoding:NSUTF8StringEncoding];
    NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
                        (unsigned long)operation,datParameter, [data convertToBase64EncodedString]];
    
    if ([[LoginService instance] sessionId]){
        params = [NSString stringWithFormat:@"%@%@", params , [NSString stringWithFormat:@"&ssid=%@", [[LoginService instance] sessionId]]];
    }
    
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[params length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:kPFRequestTimeoutInterval];
    
    NSDictionary *cookieDict = [CookieTools JSessionID];
    
    if (cookieDict != nil) {
        [request setAllHTTPHeaderFields:cookieDict];
        [request setHTTPShouldHandleCookies:YES];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else {
            Parser *parser = [Parser new];
            [parser parseUserRoles:data success:^(NSDictionary *content) {
                success(content);
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    }] resume];

}

@end
