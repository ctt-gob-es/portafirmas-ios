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

+ (void) subscribeDevice:(NSString *)deviceToken withCertificate: (NSString*)certificate success: (void(^)())success failure:(void(^)(NSError *error))failure {
    NSString *opParameter = @"op";
    NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 13;
    NSString *dataStringOne = @"<rqtreg plt='APNS' dvc='";
    NSString *dataStringTwo = @"'><cert>";
    NSString *dataStringThree = @"</cert></rqtreg>";
    
    NSString *dataString = [NSString stringWithFormat:@"%@%@%@%@%@",dataStringOne, deviceToken, dataStringTwo, certificate, dataStringThree];
    
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
            success();
        }
    }] resume];
}

@end
