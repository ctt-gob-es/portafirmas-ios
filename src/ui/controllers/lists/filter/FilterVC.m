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

#define SORT_CRITERIA_ARRAY @[@"Fecha", @"Asunto", @"Aplicación"]

static const CGFloat kFilterVCPickerHeight = 30.f;
static const CGFloat kFilterVCToolBarHeight = 44.f;
static const CGFloat kFilterVCDefaultMargin = 14.f;

@interface FilterVC ()
{
    UITextField *_currentTextField;
    NSDate *_startDate;
    NSDate *_endDate;
}

//@property (nonatomic, strong) IBOutlet UIButton *sortButton;
//@property (nonatomic, strong) IBOutlet UIPickerView *sortPickerView;
//@property (nonatomic, strong) IBOutlet UITextField *topicTextField;
//@property (nonatomic, strong) IBOutlet UIButton *appButton;
//@property (nonatomic, strong) IBOutlet UIPickerView *appPickerView;
//@property (nonatomic, strong) IBOutlet UITextField *startDateTextField;
//@property (nonatomic, strong) IBOutlet UITextField *endDateTextField;
//@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
//@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, strong) IBOutlet UISwitch *enableFiltersSwitch;
//
//@property (nonatomic, strong) IBOutlet UILabel *notificationTitleLabel;
//@property (nonatomic, strong) IBOutlet UILabel *notificationStateLabel;
//@property (nonatomic, strong) IBOutlet UIView *notificationView;
//@property (nonatomic, strong) IBOutlet UISwitch *notificationSwitch;
//@property (weak, nonatomic) IBOutlet UILabel *roleTitleLabel;
//@property (weak, nonatomic) IBOutlet UIView *roleSeparatorView;
//@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
//@property (weak, nonatomic) IBOutlet UIButton *roleButton;
//@property (weak, nonatomic) IBOutlet UILabel *selectedRoleNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *selectedRoleLabel;
@property (strong, nonatomic) IBOutlet UIView *filterView;

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

    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        UIApplication.sharedApplication.statusBarHidden = NO;
    }
    UIView * commonFilterView =[[NSBundle mainBundle] loadNibNamed:@"FiltersView" owner:nil options:nil][0];
    commonFilterView.frame = self.filterView.bounds;
    [self.filterView addSubview:commonFilterView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self listenNotificationAboutPushNotifications];
//    [self showChangeRoleOptionIfNeeded];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[KeyboardObserver getInstance] removeObserver:self];
//	[self removeNotificationAboutPushNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _endDateTextField.frame.origin.y + _endDateTextField.frame.size.height + 8)];
}

- (void)dealloc
{
    [[KeyboardObserver getInstance] removeObserver:self];
//    [self removeNotificationAboutPushNotifications];
}

#pragma mark - Notifications Section

//- (void) listenNotificationAboutPushNotifications {
//    [self removeNotificationAboutPushNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(finishSubscriptionProcess)
//                                                 name:@"FinishSubscriptionProcessNotification"
//                                               object:nil];
//}
//
//- (void) removeNotificationAboutPushNotifications {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishSubscriptionProcessNotification" object:nil];
//}

//- (void) shouldShowNotificationsSection {
//    if (![[LoginService instance] serverSupportLogin]) {
//        self.notificationTitleLabel.hidden = true;
//        self.notificationView.hidden = true;
//        self.notificationStateLabel.hidden = true;
//        self.notificationSwitch.hidden = true;
//    } else {
//        [self showNotificationSectionState];
//    }
//}

//- (void) showNotificationSectionState {
//
//    NSString *notificationStatePending = @"Filter_View_Push_Notification_Pending_Title".localized;
//    NSString *notificationStateSet = @"Filter_View_Push_Notification_Enabled_Title".localized;
//
//    if ([PushNotificationService instance].currentServer.userNotificationPermisionState) {
//        self.notificationStateLabel.text = notificationStateSet;
//        [self.notificationSwitch setOn:true];
//    } else  {
//        self.notificationStateLabel.text = notificationStatePending;
//        [self.notificationSwitch setOn:false];
//    }
//}

//-(IBAction)switchChanged:(UISwitch *)sender {
//
//    if([self.notificationSwitch isOn]){
//        [self initSubscriptionProcess];
//    } else {
//        [self showNotificationSectionState];
//    }
//}

//- (void) initSubscriptionProcess {
//
//    if ([self.notificationSwitch isOn]) {
//         [[PushNotificationService instance] initializePushNotificationsService:true];
//    } else {
//         [self showNotificationSectionState];
//    }
//
//}

//- (void) finishSubscriptionProcess {
//    [self showNotificationSectionState];
//}

#pragma mark - Delegate Popover

//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
//
//    return UIModalPresentationNone;
//}

#pragma mark - User Interface

//- (void)setupAppButton
//{
//    if (![[AppListXMLController sharedInstance] appsArray] || [[AppListXMLController sharedInstance] appsArray].count == 0) {
//        [_appButton setUserInteractionEnabled:NO];
//    }
//}

//- (void)addToolbar
//{
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kFilterVCToolBarHeight, self.view.frame.size.width, kFilterVCToolBarHeight)];
//
//    [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
//    [toolbar setItems:self.toolbarItems];
//    [self.view addSubview:toolbar];
//}
//
//- (void)hidePickers
//{
//    [_sortPickerView setAlpha:0];
//    [_appPickerView setAlpha:0];
//    [_datePicker setAlpha:0];
//}
//
//- (void)setupPickers
//{
//    [QuartzUtils drawShadowInView:_sortPickerView];
//    [QuartzUtils drawShadowInView:_datePicker];
//    [QuartzUtils drawShadowInView:_appPickerView];
//}

//- (void)updateContentOffsetForPicker
//{
//    [self updateContentOffsetForHeight:_datePicker.frame.size.height];
//}
//
//- (void)updateContentOffsetForKeyboard
//{
//    [self updateContentOffsetForHeight: _datePicker.frame.size.height];
//}
//
//- (void)updateContentOffsetForHeight:(CGFloat)height
//{
//    if (height != SCREEN_HEIGHT && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
//        CGFloat offsetY = height - (self.view.frame.size.height - (_currentTextField.frame.size.height + _currentTextField.frame.origin.y) - kFilterVCToolBarHeight - kFilterVCDefaultMargin);
//
//        if (_scrollView.contentOffset.y != offsetY) {
//            [_scrollView setContentOffset:CGPointMake(0, offsetY > 0 ? offsetY : 0) animated:YES];
//        }
//    }
//}

//- (void) showChangeRoleOptionIfNeeded {
//    self.roleTitleLabel.text = @"User_Roles_Title".localized;
//    self.roleLabel.text = @"User_Roles_Change_Role".localized;
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoles]) {
//        self.roleTitleLabel.hidden = NO;
//        self.roleSeparatorView.hidden = NO;
//        self.roleLabel.hidden = NO;
//        self.roleButton.hidden = NO;
//        self.selectedRoleNameLabel.hidden = NO;
//        self.selectedRoleLabel.hidden = NO;
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected]) {
//            self.selectedRoleNameLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleUserNameKey] objectForKey:kContentKey];
//            self.selectedRoleLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey];
//        } else {
//            self.selectedRoleNameLabel.hidden = YES;
//            self.selectedRoleLabel.text = @"User_Role_Signer".localized;
//        }
//    } else {
//        self.roleTitleLabel.hidden = YES;
//        self.roleSeparatorView.hidden = YES;
//        self.roleLabel.hidden = YES;
//        self.roleButton.hidden = YES;
//        self.selectedRoleNameLabel.hidden = YES;
//        self.selectedRoleLabel.hidden = YES;
//    }
//}

#pragma mark - User Interaction

//- (IBAction)didClickCancelButton:(id)sender
//{
//   dispatch_async(dispatch_get_main_queue(), ^{
//	   [self dismissViewControllerAnimated:YES completion:nil];
//	});
//}

//- (IBAction)didClickAcceptButton:(id)sender
//{
//    NSMutableDictionary *filters = [@{} mutableCopy];
//
//    if (![_sortButton.titleLabel.text isEqualToString:@"Selecciona un criterio de ordenación"]) {
//        NSString *sortValue = [PFHelper getPFSortCriteriaValueForRow:[_sortPickerView selectedRowInComponent:0]];
//
//        if (sortValue) {
//            filters[kPFFilterKeySortCriteria] = sortValue;
//            filters[kPFFilterKeySort] = kPFFilterValueSortDesc;
//        }
//    }
//
//    if ([_enableFiltersSwitch isOn]) {
//
//        if (_topicTextField.text && _topicTextField.text.length > 0) {
//            filters[kPFFilterKeySubject] = _topicTextField.text;
//        }
//        if (![_appButton.titleLabel.text isEqualToString:@"Selecciona una aplicación"]) {
//            filters[kPFFilterKeyApp] = [[AppListXMLController sharedInstance] appsArray][[_sortPickerView selectedRowInComponent:0]];
//        }
//        if (_startDateTextField.text && _startDateTextField.text.length > 0) {
//            filters[kPFFilterKeyDateStart] = _startDateTextField.text;
//        }
//        if (_endDateTextField.text && _endDateTextField.text.length > 0) {
//            filters[kPFFilterKeyDateEnd] = _endDateTextField.text;
//        }
//    }
//
//    UITabBarController *tabController;
//
//    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
//
//        UINavigationController *nav = (UINavigationController *)self.presentingViewController;
//        UIViewController *settingsVC = nav.rootViewController;
//        tabController = (UITabBarController *)settingsVC.presentedViewController;
//
//    }
//    else if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
//
//        tabController = (UITabBarController *)self.presentingViewController;
//    }
//
//    UINavigationController *navigation = (UINavigationController *) tabController.selectedViewController;
//    BaseListTVC *baseTVC = (BaseListTVC *)navigation.rootViewController;
//
//    [baseTVC setFiltersDict:filters.count > 0 ? filters:nil];
//
//    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
//
//        [self.navigationController popViewControllerAnimated:YES];
//        [baseTVC refreshInfoWithFilters:filters];
//    }
//
//	dispatch_async(dispatch_get_main_queue(), ^{
//	  [self dismissViewControllerAnimated:YES completion:^{
//		   [baseTVC refreshInfoWithFilters:filters];
//	   }];
//	});
//}

//- (IBAction)didClickSortCriteriaButton:(id)sender
//{
//    [self hidePickers];
//    [self.view endEditing:YES];
//    [UIView animateWithDuration:0.3 animations:^{
//         [self.sortPickerView setAlpha:1];
//     }];
//}
//
//- (IBAction)didClickAppButton:(id)sender
//{
//    if ([[AppListXMLController sharedInstance] appsArray] && [[AppListXMLController sharedInstance] appsArray].count > 0) {
//        [self hidePickers];
//        [self.view endEditing:YES];
//        [UIView animateWithDuration:0.3 animations:^{
//			[self.appPickerView setAlpha:1];
//         }];
//    }
//}
//
//- (IBAction)didUpdateValueForFilterSwitch:(id)sender
//{
//    BOOL enable = [sender isOn];
//
//    [_topicTextField setEnabled:enable];
//    [_appButton setEnabled:(![[AppListXMLController sharedInstance] appsArray] || [[AppListXMLController sharedInstance] appsArray].count == 0) ? NO:enable];
//    [_startDateTextField setEnabled:enable];
//    [_endDateTextField setEnabled:enable];
//    [self hidePickers];
//}
//
//- (IBAction)didUpdateValueForDatePicker:(id)sender
//{
//    [_currentTextField setText:[_datePicker.date stringWithFormat:kPFDefaultDateFormat]];
//
//    if ([_currentTextField isEqual:_startDateTextField]) {
//        [self updateValuesForStartDate];
//    } else {
//        [self updateValuesForEndDate];
//    }
//
//    [self performSelector:@selector(hidePickers) withObject:nil afterDelay:0.5];
//    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//}
//
//- (void)updateValuesForStartDate
//{
//    _startDate = _startDateTextField.text ? [DateHelper getDateFromString:_startDateTextField.text] : nil;
//
//    if (_startDate && _endDate && [_startDate isGreaterThan:_endDate] > 0 ) {
//        _endDate = _startDate;
//        [_endDateTextField setText:_startDateTextField.text];
//    }
//}
//
//- (void)updateValuesForEndDate
//{
//    _endDate = _endDateTextField.text ? [DateHelper getDateFromString:_endDateTextField.text] : nil;
//
//    if (_startDate && _endDate && [_endDate isMinorThan:_startDate] ) {
//        _startDate = _endDate;
//        [_startDateTextField setText:_endDateTextField.text];
//    }
//}

#pragma mark - UIPickerViewDataSource

//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    if ([pickerView isEqual:_sortPickerView]) {
//        return SORT_CRITERIA_ARRAY.count;
//    } else if ([pickerView isEqual:_appPickerView]) {
//        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray].count : 0;
//    }
//
//    return 0;
//}

#pragma mark - UIPickerViewDelegate

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if ([pickerView isEqual:_sortPickerView]) {
//        return SORT_CRITERIA_ARRAY[row];
//    } else if ([pickerView isEqual:_appPickerView]) {
//        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray][row] : nil;
//    }
//
//    return nil;
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//    return kFilterVCPickerHeight;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if ([pickerView isEqual:_sortPickerView]) {
//        [_sortButton setTitle:SORT_CRITERIA_ARRAY[row] forState:UIControlStateNormal];
//        [_sortButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    } else if ([pickerView isEqual:_appPickerView]) {
//        [_appButton setTitle:[[AppListXMLController sharedInstance] appsArray][row] forState:UIControlStateNormal];
//        [_appButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
//
//    [self performSelector:@selector(hidePickers) withObject:nil afterDelay:0.5];
//}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    _currentTextField = textField;
//
//    if ([_currentTextField isEqual:_topicTextField]) {
//        [self hidePickers];
//        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//
//        return YES;
//    } else {
//
//        [self.view endEditing:YES];
//		_datePicker.backgroundColor = [UIColor whiteColor];
//        if ([_currentTextField isEqual:_startDateTextField]) {
//            if (_startDate) {
//                [_datePicker setDate:_startDate];
//            } else if (_endDate) {
//                [_datePicker setDate:_endDate];
//            } else {
//                [_datePicker setDate:[NSDate date]];
//            }
//        } else {
//            if (_endDate) {
//                [_datePicker setDate:_endDate];
//            } else if (_startDate) {
//                [_datePicker setDate:_startDate];
//            } else {
//                [_datePicker setDate:[NSDate date]];
//            }
//        }
//
//        [UIView animateWithDuration:0.3 animations:^{
//			[self.datePicker setAlpha:1.0];
//         } completion:^(BOOL finished) {
//             [self updateContentOffsetForPicker];
//         }];
//
//        return NO;
//    }
//
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self updateContentOffsetForKeyboard];
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//
//    return YES;
//}

#pragma mark - Keyboard Notifications

//- (void)handleKeyboardChange
//{
//    if (isKeyboardShowed) {
//        [self updateContentOffsetForKeyboard];
//    } else if (isKeyboardHiding) {
//        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
//}
//- (IBAction)tapChangeRole:(id)sender {
//    SelectRoleViewController *selectRoleViewController = [[SelectRoleViewController alloc] initWithNibName: @"SelectRoleViewController" bundle: nil];
//    [selectRoleViewController setModalPresentationStyle:UIModalPresentationFullScreen];
//    [self presentViewController:selectRoleViewController animated:YES completion:nil];
//}

@end
