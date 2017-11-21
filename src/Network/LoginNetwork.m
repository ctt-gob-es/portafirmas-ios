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

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation LoginNetwork

+ (void) loginProcess:(void(^)(NSString *token))success failure:(void(^)(NSError *error))failure {
    
   // NSString *opParameter = @"op";
   // NSString *datParameter = @"dat";
    NSString *baseURL = SERVER_URL;
    NSInteger operation = 10;
    NSString *dataString = @"<lgnrq />";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *params = [NSString stringWithFormat: @"op=%lu&dat=%@",
                      (unsigned long)operation, [data base64EncodedString]];
    
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:SERVER_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        } else  {
            //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            //NSLog(@"Request reply: %@", requestReply);
            Parser *parser = [Parser new];
            
            [parser parseAuthData:data success:^(NSString *token) {
                success(token);
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    }] resume];
}
@end
