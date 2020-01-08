//
//  RequestCellNoUI.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 26/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "RequestCellNoUI.h"
#import "DateHelper.h"

@implementation RequestCellNoUI

- (void)setPFRequest:(PFRequest *)request
{
    [_title setText:request.snder];
    [_detail setText:request.subj];
    [_inputDate setText:request.date];
    [self getExpirationLabelValue:request.expdate];
    [self setupRequestTypeIcon:request.type];
    [self setBackgroundColor: [DateHelper isNearToExpire:request.expdate inDays:DAYS_TO_EXPIRE_FOR_HIGHLIGHT] ? HIGHLIGHT_COLOR_FOR_NEAR_TO_EXPIRE_CELLS : (request.isNew ? ThemeColorWithAlpha(0.08) : [UIColor clearColor])];
}

- (void)getExpirationLabelValue:(NSString *)expirationDate {
    _expirationDate.hidden = expirationDate == nil;
    if (expirationDate){
        NSString* expirationDateText = [@"Expiration_text_message".localized stringByAppendingString:expirationDate];
        [_expirationDate setText:expirationDateText];
    }
}

- (void)setupRequestTypeIcon:(PFRequestType)type
{
    NSString *iconImageName = type == PFRequestTypeSign ? @"icn_firma" : @"icn_check";

    [_iconRequestType setImage:[QuartzUtils getImageWithName:iconImageName andTintColor:THEME_COLOR]];
}

@end
