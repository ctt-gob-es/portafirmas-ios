//
//  RequestCell.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 26/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "RequestCell.h"
#import "PFCellContentFactory.h"

@interface RequestCell ()
{
    CALayer *_priorityIconLayer;
    UILabel *_priorityLabel;
}

@end

@implementation RequestCell : UITableViewCell

- (void)setPFRequest:(PFRequest *)request
{
    [_title setText:request.snder];
    [_detail setText:request.subj];
    [_inputDate setText:request.date];
    [self getExpirationLabelValue:request.expdate];
    [self setupPriorityIcon:request.priority];
    [self setupRequestTypeIcon:request.type];
    //Prepare the Background for hightlight
    [self setBackgroundColor: [self isNearToExpire:request.date] ? [UIColor redColor] : (request.isNew ? ThemeColorWithAlpha(0.08) : [UIColor clearColor])];
}

- (void)getExpirationLabelValue:(NSString *)expirationDate {
    _expirationDate.hidden = expirationDate == nil;
    if (expirationDate){
        NSString* expirationDateText = [NSLocalizedString(@"Expiration_text_message", nil) stringByAppendingString:expirationDate];
        [_expirationDate setText:expirationDateText];
    }
}

- (BOOL)isNearToExpire: (NSString *)expirationDate {
    //Do the logic to know if the expiration is in three days.
    return true;
}

- (void)setupPriorityIcon:(NSString *)priority
{
    _priorityIconLayer = [PFCellContentFactory iconLayerForPriority:priority withSize:_image.frame.size.height];

    if (_priorityIconLayer) {
        [self initPriorityLabel];
        [_image.layer addSublayer:_priorityIconLayer];
        [_image addSubview:_priorityLabel];
    }
}

- (void)setupRequestTypeIcon:(PFRequestType)type
{
    NSString *iconImageName = type == PFRequestTypeSign ? @"icn_firma" : @"icn_check";

    [_iconRequestType setImage:[QuartzUtils getImageWithName:iconImageName andTintColor:THEME_COLOR]];
}

- (void)initPriorityLabel
{
    if (!_priorityLabel) {
        _priorityLabel = [[UILabel alloc] initWithFrame:_image.bounds];
        [_priorityLabel setText:@"!"];
        [_priorityLabel setBackgroundColor:[UIColor clearColor]];
        [_priorityLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_priorityLabel setTextColor:[UIColor whiteColor]];
        [_priorityLabel setTextAlignment:NSTextAlignmentCenter];
    }
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [_priorityIconLayer removeFromSuperlayer];
    _priorityIconLayer = nil;
    [_priorityLabel removeFromSuperview];
}

@end
