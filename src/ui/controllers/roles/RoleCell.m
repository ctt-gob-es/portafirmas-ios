//
//  RoleCell.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import "RoleCell.h"
#import "UIFont+Styles.h"

@implementation RoleCell

-(void)setCellIcon:(NSString *)icon tintColor: (UIColor*)color {
    [self.roleIconImage setImage:[QuartzUtils getImageWithName:icon andTintColor:color]];
}

-(void)setCellTitle: (NSString *)title {
    self.roleTitleLabel.text = title;
}

-(void)setCellSubtitle: (NSString *)subtitle {
    self.roleSubtitleLabel.text = subtitle;
    self.roleSubtitleLabel.textColor =[UIColor lightGrayColor];
}

-(void)hideSubtitle {
    [self.roleSubtitleLabel setHidden:YES];
}
@end
