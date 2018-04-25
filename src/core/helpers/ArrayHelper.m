//
//  DateHelper.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/3/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "ArrayHelper.h"
#import "NSDateFormatter+Utils.h"
#import "PFRequest.h"

@implementation ArrayHelper

+ (NSMutableArray *)getSortedArrayByExpirationDate: (NSMutableArray *)array {
    NSArray *arraySorted = [array sortedArrayUsingFunction:dateSort context:nil];
    NSMutableArray *mutableArraySorted = [[NSMutableArray alloc] initWithArray:arraySorted];
    return mutableArraySorted;
}

//The sort function for date
NSComparisonResult dateSort(PFRequest *element1, PFRequest *element2, void *context) {
    NSString *string1 = [element1 valueForKey:@"expdate"];
    NSString *string2 = [element2 valueForKey:@"expdate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *d1 = [formatter dateFromString:string1];
    NSDate *d2 = [formatter dateFromString:string2];
    if ([element1 valueForKey:@"expdate"] && ![element2 valueForKey:@"expdate"]) {
        return NSOrderedAscending;
    }
    if (![element1 valueForKey:@"expdate"] && [element2 valueForKey:@"expdate"]) {
        return NSOrderedDescending;
    }
    return [d1 compare:d2]; // ascending order
}

@end
