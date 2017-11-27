//
//  NSString+XMLSafe.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 23/11/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "NSString+XMLSafe.h"

@implementation NSString (XMLSafe)

- (NSString *)xmlSafeString {
   NSString *first = [self stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    NSString *second = [first stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    
    return second;
}
@end
