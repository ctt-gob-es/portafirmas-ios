    //
    //  RequestCell.m
    //  PortaFirmasUniv
    //
    //  Created by Antonio Fiñana on 26/11/12.
    //  Copyright (c) 2012 Atos. All rights reserved.
    //

#import "RequestCell.h"
#import "PFCellContentFactory.h"
#import "DateHelper.h"

@interface RequestCell ()
{
    CALayer *_priorityIconLayer;
    UILabel *_priorityLabel;
}

@end

@implementation RequestCell : UITableViewCell

- (void)setPFRequest:(PFRequest *)request
{
        // Get if Expanded View selected in Settings
    Boolean displayExpandedView = [[NSUserDefaults standardUserDefaults] boolForKey: kPFUserDefaultsKeyUserSelectionFilterDisplayExpandedViewSelected];
    
        // Title
    [_title setText:request.snder];
        // Title (max number of lines)
    [_title setNumberOfLines: displayExpandedView ? 0 : 1];
    [_title setLineBreakMode: displayExpandedView ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail];
    
        // Detail
    [_detail setText:request.subj];
        // Detail (max number of lines)
    [_detail setNumberOfLines: displayExpandedView ? 0 : 1];
    [_detail setLineBreakMode: displayExpandedView ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail];
    
        // Input date
    [_inputDate setText:request.date];
        // Input date (max number of lines)
    [_inputDate setNumberOfLines: displayExpandedView ? 0 : 1];
    [_inputDate setLineBreakMode: displayExpandedView ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail];
    [self getExpirationLabelValue:request.expdate];
    [self setupPriorityIcon:request.priority];
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
        // TODO test: before 14
        [_priorityLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [_priorityLabel setTextColor:[UIColor whiteColor]];
        [_priorityLabel setTextAlignment:NSTextAlignmentCenter];
    }
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_priorityIconLayer removeFromSuperlayer];
    _priorityIconLayer = nil;
    [_priorityLabel removeFromSuperview];
}

@end
