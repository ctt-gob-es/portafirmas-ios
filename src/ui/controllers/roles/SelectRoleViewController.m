//
//  SelectRoleViewController.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectRoleViewController.h"
#import "RoleCell.h"
#import "UIColor+Styles.h"

static NSString *const kRoleCell = @"roleCell";
static NSString *const kRoleCellNibName = @"RoleCell";
static NSString *const kContentKey =@"content";
static NSString *const kUserNameKey = @"userName";
static NSString *const kRoleNameKey = @"roleName";

@interface SelectRoleViewController()

@end

@implementation SelectRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectRoleTitleLabel.textColor = [UIColor userRolesTitleColorRed];
    [self.roleTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.roleTableView.scrollEnabled = NO;
    _rolesArray = [[NSUserDefaults standardUserDefaults] objectForKey:kPFCertInfoKeyUserRoles];
}

- (NSInteger)numberOfRoles {
    return _rolesArray.count;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRoles] + 1;
}

#pragma mark - UITableViewDelegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoleCell];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:kRoleCellNibName bundle:nil] forCellReuseIdentifier:kRoleCell];
        cell = [tableView dequeueReusableCellWithIdentifier:kRoleCell];
    }
    if(indexPath.row == 0) {
        [cell setCellIcon:@"icn_firma" tintColor: THEME_COLOR];
        [cell setCellTitle: @"User_Roles_Signer_Cell_Title".localized];
        [cell hideSubtitle];
    } else {
        [cell setCellIcon:@"icn_check" tintColor: [UIColor greenColor]];
        [cell setCellTitle: [[_rolesArray[indexPath.row - 1] objectForKey:kUserNameKey] objectForKey:kContentKey]];
        [cell setCellSubtitle:[[_rolesArray[indexPath.row - 1] objectForKey:kRoleNameKey] objectForKey:kContentKey]];
    }
    
    return cell;
}

@end
