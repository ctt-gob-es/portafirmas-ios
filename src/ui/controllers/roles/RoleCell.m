//
//  RoleCell.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import "RoleCell.h"

@implementation RoleCell

-(void)setCellIcon:(NSString *)icon tintColor: (UIColor*)color {
    [self.roleIconImage setImage:[QuartzUtils getImageWithName:icon andTintColor:color]];
}

@end
