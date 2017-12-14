//
//  ErrorService.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 14/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorService : NSObject
+ (ErrorService *)instance;
- (void) showLoginErrorAlertView;
@end

