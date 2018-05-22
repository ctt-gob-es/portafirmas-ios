//
//  DetailCell.m
//  PortaFirmasUniv
//
//  Created by Sergio PH on 15/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellTitle:(NSString *)value
{
    self.titleLabel.text = value;
    [self.titleLabel sizeToFit];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
}

-(void)setCellValue:(NSString *)value
{
    self.valueLabel.text = value;
}

-(void)setDarkStyle
{
    UIFont *headerFont = [ UIFont fontWithName: @"Helvetica" size: 17.0 ];
    self.titleLabel.font = headerFont;
    self.valueLabel.font = headerFont;
}

-(void)setValueBoldStyle
{
    [self setBoldStyle: self.valueLabel];
}

-(void)setTitleBoldStyle
{
    [self setBoldStyle: self.titleLabel];
}

-(void)setBoldStyle:(UILabel*)label
{
    if (![label.font.fontName containsString: @"Bold"]) {
    label.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",label.font.fontName] size:label.font.pointSize];
    }
}

-(void)setValueInNewViewStyle
{
    CGRect frameRect = self.titleLabel.frame;
    frameRect.size.width = 300;
    self.titleLabel.frame = frameRect;
    [self setTitleBoldStyle];
}

-(void)setClearStyle
{
    UIFont *titleFont = [ UIFont fontWithName: @"Helvetica" size: 16.0 ];
    self.titleLabel.font = titleFont;
    self.titleLabel.textColor = [UIColor colorWithRed:160.0f/255.0f
                                                green:160.0f/255.0f
                                                blue:160.0f/255.0f
                                                alpha:1.0f];
    UIFont *valueFont = [ UIFont fontWithName: @"Helvetica" size: 14.0 ];
    self.valueLabel.font = valueFont;
    self.valueLabel.textColor = [UIColor colorWithRed:87.0f/255.0f
                                                green:87.0f/255.0f
                                                 blue:87.0f/255.0f
                                                alpha:1.0f];
    
}

-(void)hideLabelsIfNeeded:(BOOL)hidden
{
    for (UILabel* label in self.labels) {
        label.hidden = hidden;
    }
}

-(void)increaseTitleLabelWidth:(CGFloat)width
{
    self.titleConstraintWidth.constant = width;
}

@end
