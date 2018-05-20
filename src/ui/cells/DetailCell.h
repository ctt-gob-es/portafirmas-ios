//
//  DetailCell.h
//  PortaFirmasUniv
//
//  Created by Sergio PH on 15/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell

-(void)setCellValue:(NSString *)value;
-(void)setCellTitle:(NSString *)value;
-(void)setDarkStyle;
-(UIFont*)setBoldStyle;
-(void)setValueInNewViewStyle;
-(void)setClearStyle;
-(void)hideLabels;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end
