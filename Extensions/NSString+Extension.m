//
//  NSString+Extension.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 08/01/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Extension.h"

@implementation NSString (Common)

- (NSString *) localized {
	return NSLocalizedString(self, nil);
}

@end
