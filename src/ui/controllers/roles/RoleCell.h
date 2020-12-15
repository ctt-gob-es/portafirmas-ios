//
//  RoleCell.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoleCell : UITableViewCell

-(void)setCellIcon:(UIImage *)icon tintColor: (UIColor*)color;

@property (weak, nonatomic) IBOutlet UIImageView *roleIconImage;
@property (weak, nonatomic) IBOutlet UILabel *roleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rolSubTitleLabel;

@end
