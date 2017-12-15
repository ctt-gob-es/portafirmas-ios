//
//  ServerManager.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 15/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject
- (void) addServer: (NSString *) url withToken: (NSString *) token;
@end
