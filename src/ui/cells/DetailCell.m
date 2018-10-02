//
//  DetailCell.m
//  PortaFirmasUniv
//
//  Created by Sergio PH on 15/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "DetailCell.h"
#import "UIFont+Styles.h"
#import "UIColor+Styles.h"

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
    UIFont *headerFont = [UIFont headerFontStyle];
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
    UIFont *titleFont = [UIFont clearStyleTitleDetailCell];
    self.titleLabel.font = titleFont;
    self.titleLabel.textColor = [UIColor clearStyleTitleDetailCell];
    UIFont *valueFont = [UIFont clearStyleValueDetailCell];
    self.valueLabel.font = valueFont;
    self.valueLabel.textColor =[UIColor clearStyleValueDetailCell];
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
