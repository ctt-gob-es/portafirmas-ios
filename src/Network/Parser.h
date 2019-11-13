//
//  Parser.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 21/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Parser : NSObject
- (void) parseAuthData: (NSData *)data success: (void(^)(NSString *token))success failure:(void(^)(NSError *))failure;
- (void) parseAuthWithRemoteCertificates: (NSData *)data success: (void(^)(NSDictionary *content))success failure:(void(^)(NSError *))failure;
- (void) parseValidateData: (NSData *)data success: (void(^)(BOOL isValid))success failure:(void(^)(NSError *))failure;
- (void) parseValidateSubscription: (NSData *)data success: (void(^)(BOOL isValid))success failure:(void(^)(NSError *))failure;
@end
