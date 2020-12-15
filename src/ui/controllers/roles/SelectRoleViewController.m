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

static NSString *const kRoleCell = @"roleCell";
static NSString *const kRoleCellNibName = @"RoleCell";
CGFloat const defaultRoleCellHeight = 44;

@interface SelectRoleViewController()

@end

@implementation SelectRoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.roleTableView.estimatedRowHeight = defaultRoleCellHeight;
    self.roleTableView.rowHeight = UITableViewAutomaticDimension;
    [self.roleTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.roleTableView.scrollEnabled = NO;
    _rolesDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPFCertInfoKeyUserRoles];
}

- (NSInteger)numberOfRoles {
    return _rolesDictionary.count;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRoles];
}

#pragma mark - UITableViewDelegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoleCell];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:kRoleCellNibName bundle:nil] forCellReuseIdentifier:kRoleCell];
        cell = [tableView dequeueReusableCellWithIdentifier:kRoleCell];
    }
    return cell;
}

@end
