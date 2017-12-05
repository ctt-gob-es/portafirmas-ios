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
@end
