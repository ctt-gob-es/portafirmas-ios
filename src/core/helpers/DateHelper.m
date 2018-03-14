//
//  DateHelper.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 12/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "DateHelper.h"
#import "NSDateFormatter+Utils.h"

@implementation DateHelper

+ (NSString *)getStringFromDate:(NSDate *)date
{
    return [self getStringFromDate:date withFormat:kPFDefaultDateFormat];
}

+ (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format
{
    if (!date) {
        return nil;
    }
    
    NSDateFormatter * df = [[NSDateFormatter alloc] initWithCurrentLocale];
    [df setDateFormat:format];
    
    return [df stringFromDate:date];
}

+ (NSDate *)getDateFromString:(NSString *)stringDate
{
    return [self getDateFromString:stringDate withFormat:kPFDefaultDateFormat];
}

+ (NSDate *)getDateFromString:(NSString *)stringDate withFormat:(NSString *)format
{
    if (stringDate) {
        NSDateFormatter *df = [[NSDateFormatter alloc] initWithCurrentLocale];
        [df setDateFormat:format];

        return [df dateFromString:stringDate];
    }

    return nil;
}

+ (NSDate *)getGreaterDate:(NSArray *)datesArray
{
    NSArray *sortedDatesArray = [datesArray sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
                                     if ([obj1 isKindOfClass:[NSDate class]] && [obj2 isKindOfClass:[NSDate class]]) {
                                         return [(NSDate *)obj1 compare : (NSDate *)obj2];
                                     }

                                     return nil;
                                 }];

    return sortedDatesArray[0];
}

+ (BOOL)isNearToExpire: (NSString *)expirationDate inDays: (int) days{
    NSDate *dateForExpiration = [DateHelper getDateFromString:expirationDate];
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:dateForExpiration toDate:currentDate options:0];
    return ([components day] < days) && expirationDate? true : false;
}

@end
