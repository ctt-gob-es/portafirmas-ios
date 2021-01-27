//
//  SelectRoleViewController.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertificateUtils.h"

@protocol RoleSelectedDelegate
- (void) rolesSelected;
@end

@interface SelectRoleViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,weak)id<RoleSelectedDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *selectRoleTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *roleTableView;
@property (nonatomic, strong) NSArray *rolesArray;

@end
