//
//  DetailCell.h
//  PortaFirmasUniv
//
//  Created by Sergio PH on 15/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface DetailCell : UITableViewCell<TTTAttributedLabelDelegate>

-(void)setCellValue:(NSString *)value;
-(void)setCellTitle:(NSString *)value;
-(void)setDarkStyle;
-(void)setValueInNewViewStyle;
-(void)setClearStyle;
-(void)hideLabelsIfNeeded:(BOOL)hidden;
-(void)increaseTitleLabelWidth:(CGFloat)width;
-(void)setValueBoldStyle;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleConstraintWidth;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *valueLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end
