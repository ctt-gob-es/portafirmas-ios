//
//  FilterVC.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 11/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "FilterVC.h"
#import "DateHelper.h"
#import "NSDate+Utils.h"
#import "AppListXMLController.h"
#import "BaseListTVC.h"
#import "LoginService.h"
#import "ServerManager.h"
#import "Server.h"
#import "PushNotificationService.h"
#import "SelectRoleViewController.h"
#import "GlobalConstants.h"
#import "PFHelper.h"
#import "FiltersView.h"

static const CGFloat kFilterVCPickerHeight = 30.f;
static const CGFloat kFilterVCToolBarHeight = 44.f;
static const CGFloat kFilterVCDefaultMargin = 14.f;

@interface FilterVC () {
    UITextField *_currentTextField;
    NSDate *_startDate;
    NSDate *_endDate;
}

@property (strong, nonatomic) FiltersView* filterView;
@property (strong, nonatomic) IBOutlet UIView *filterViewContainerView;

@end

@implementation FilterVC

#pragma mark - Init methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        
        [[KeyboardObserver getInstance] addObserver:self];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self addToolbar];
//    [self shouldShowNotificationsSection];
//    [self hidePickers];
//    [self setupPickers];

//    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _endDateTextField.frame.origin.y + _endDateTextField.frame.size.height + kFilterVCDefaultMargin)];
//    [_enableFiltersSwitch setFrame:CGRectMake(self.view.frame.size.width - _enableFiltersSwitch.frame.size.width - kFilterVCDefaultMargin, _enableFiltersSwitch.frame.origin.y, _enableFiltersSwitch.frame.size.width, _enableFiltersSwitch.frame.size.height)];

    [self.parentViewController.tabBarController.tabBar setHidden:YES];
    
    if ([[UIDevice currentDevice].model isEqualToString:kPFDeviceModeliPhone]) {
        UIApplication.sharedApplication.statusBarHidden = NO;
    }
    _filterView =[[NSBundle mainBundle] loadNibNamed:@"FiltersView" owner:nil options:nil][0];
    _filterView.frame = self.filterViewContainerView.bounds;
    _filterView.filtersViewDelegate = self;
    [self.filterViewContainerView addSubview:_filterView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self listenNotificationAboutPushNotifications];
//    [self showChangeRoleOptionIfNeeded];
    [_filterView showChangeRoleOptionIfNeeded];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[KeyboardObserver getInstance] removeObserver:self];
}

- (void)dealloc
{
    [[KeyboardObserver getInstance] removeObserver:self];
}

#pragma mark - User Interaction

- (void)didSelectAcceptButton: (NSMutableDictionary *) selectedFilters {
    NSMutableDictionary *filters = [selectedFilters mutableCopy];
    UITabBarController *tabController;
    if ([[UIDevice currentDevice].model isEqualToString:kPFDeviceModeliPhone]) {
        
        UINavigationController *nav = (UINavigationController *)self.presentingViewController;
        UIViewController *settingsVC = nav.rootViewController;
        tabController = (UITabBarController *)settingsVC.presentedViewController;
    }
    else if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        tabController = (UITabBarController *)self.presentingViewController;
    }
    UINavigationController *navigation = (UINavigationController *) tabController.selectedViewController;
    BaseListTVC *baseTVC = (BaseListTVC *)navigation.rootViewController;
    [baseTVC setFiltersDict:filters.count > 0 ? filters:nil];
    if ([[UIDevice currentDevice].model isEqualToString:kPFDeviceModeliPhone]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSettingsDismissNotification
         object:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kSettingsDismissNotification
             object:self];
            [baseTVC refreshInfoWithFilters:filters];
        }];
    });
}

- (void)didSelectCancelButton {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - TapChangeRoleDelegate

- (void)tapChangeRole {
    SelectRoleViewController *selectRoleViewController = [[SelectRoleViewController alloc] initWithNibName: @"SelectRoleViewController" bundle: nil];
    [selectRoleViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:selectRoleViewController animated:YES completion:nil];
}

@end
