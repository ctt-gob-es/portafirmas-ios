//
//  DateHelper.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/3/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "ArrayHelper.h"
#import "NSDateFormatter+Utils.h"

@implementation ArrayHelper

+ (NSMutableArray *)getSortedArrayByExpirationDateAndDate: (NSMutableArray *)array {
    NSSortDescriptor *sortByExpirationDate = [self getSortDescriptorWithKey:@"expdate" ascending:YES];
    NSSortDescriptor *sortByDate = [self getSortDescriptorWithKey:@"date" ascending:NO];
    return [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:@[sortByExpirationDate, sortByDate]]];
}

+ (NSSortDescriptor *)getSortDescriptorWithKey: (NSString *)key ascending:(BOOL) ascending {
    return [[NSSortDescriptor alloc] initWithKey:key ascending: ascending];
}

@end
