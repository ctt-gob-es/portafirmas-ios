//
//  SettingsVC.h
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 16/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerListTVC.h"
#import "SettingsCell.h"
#import <WebKit/WebKit.h>
#import "SelectRoleViewController.h"

@interface SettingsVC : PFBaseTVC <ServerListTVCDelegate, SettingsCellDelegate, UIWebViewDelegate, WKNavigationDelegate, RoleSelectedDelegate>

@end
