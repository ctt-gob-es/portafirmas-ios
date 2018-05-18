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
}

-(void)setCellValue:(NSString *)value
{
    self.valueLabel.text = value;
}

-(void)setHeaderStyle
{
    UIFont *headerFont = [ UIFont fontWithName: @"Helvetica" size: 17.0 ];
    self.titleLabel.font = headerFont;
    self.valueLabel.font = headerFont;
}

-(void)setBoldStyle
{
    UIFont *currentFont = self.valueLabel.font;
    UIFont *newBoldFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    self.valueLabel.font = newBoldFont;
}

-(void)setValueInNewViewStyle
{
    
}

@end
