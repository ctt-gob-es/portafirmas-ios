//
//  PushNotificationNetwork.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 8/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "PushNotificationNetwork.h"

@implementation PushNotificationNetwork

+ (void)subscribeToken:(NSString *)deviceToken success:(void(^)())success failure:(void(^)(NSError *))failure {
    
    NSString *baseURL = @"https://pre-portafirmas.redsara.es/pfmovil_savetoken/token";
    NSString *tokenParameter = @"token";
    
    NSString *postString = [NSString stringWithFormat:@"%@=%@", tokenParameter, deviceToken];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    //NSData *postData = [deviceToken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
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

@end
