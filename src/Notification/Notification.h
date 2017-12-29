//
//  Notification.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 29/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject
@property (nonatomic, strong) NSString *alertBody;
@property (nonatomic, strong) NSString *alertTitle;

- (id) initWithUserInfo: (NSDictionary *) userInfo;
@end
