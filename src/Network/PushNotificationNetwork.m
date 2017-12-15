//
//  PushNotificationNetwork.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 8/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "PushNotificationNetwork.h"
#import "NSData+Base64.h"
#import "Parser.h"
#import "NSString+XMLSafe.h"
#import "CookieTools.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation PushNotificationNetwork

+ (void)subscribeToken:(NSString *)deviceToken success:(void(^)())success failure:(void(^)(NSError *))failure {
    
    NSString *baseURL = @"https://pre-portafirmas.redsara.es/pfmovil_savetoken/token";
    NSString *tokenParameter = @"token";
    
    NSString *postString = [NSString stringWithFormat:@"%@=%@", tokenParameter, deviceToken];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"Request reply: %@", requestReply);
            success();
        }
    }] resume];
}

+ (void) subscribeDevice:(NSString *)deviceID withToken: (NSString*)token success: (void(^)())success failure:(void(^)(NSError *error))failure {
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 13;
    NSString *dataStringOne = @"<rqtreg plt=\"2\" dvc=\"";
    NSString *dataStringTwo = @"\" tkn=\"";
    NSString *dataStringThree = @"\"/>";
    
    NSString *dataString = [NSString stringWithFormat:@"%@%@%@%@%@",dataStringOne, deviceID, dataStringTwo, token, dataStringThree];
    
    //NSString *xmlSafeString = [dataString xmlSafeString];
    NSData *data = [dataString  dataUsingEncoding:NSUTF8StringEncoding];
    NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
                        (unsigned long)operation,datParameter, [data base64EncodedString]];
    
  //  NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    NSDictionary *cookieDict = [CookieTools JSessionID];
    
    if (cookieDict != nil) {
        [request setAllHTTPHeaderFields:cookieDict];
        [request setHTTPShouldHandleCookies:YES];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"Request reply: %@", requestReply);
            
            Parser *parser = [Parser new];
            
            [parser parseValidateSubscription:data success:^(BOOL isValid) {
                if (isValid) {
                    success();
                }else{
                    failure(nil);
                }
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    }] resume];
}

@end
