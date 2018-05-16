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
    self.sendersTitleTextView.text = value;
}

-(void)setCellValue:(NSString *)value
{
    self.sendersTextView.text = value;
}

@end
