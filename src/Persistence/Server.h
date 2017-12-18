//
//  Server.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 15/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Server : RLMObject
@property NSString *url;
@property NSString *certificate;
@property NSString *token;
@property BOOL userNotificationPermisionState;
@end
