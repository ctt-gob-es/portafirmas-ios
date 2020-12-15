//
//  SelectRoleViewController.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/12/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertificateUtils.h"

@interface SelectRoleViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *selectRoleTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *roleTableView;
@property (nonatomic, strong) NSDictionary *rolesDictionary;

@end
