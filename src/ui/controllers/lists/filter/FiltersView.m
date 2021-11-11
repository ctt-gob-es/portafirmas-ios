//
//  FiltersView.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import "AppListXMLController.h"
#import <Foundation/Foundation.h>
#import "FiltersView.h"
#import "GlobalConstants.h"
#import "LoginService.h"
#import "PushNotificationService.h"

#import "Port_firmas-Swift.h"

#define SORT_CRITERIA_TITLE_ARRAY @[@"Filter_View_Sort_Criteria_Array_Date".localized, @"Filter_View_Sort_Criteria_Array_Topic".localized, @"Filter_View_Sort_Criteria_Array_Application".localized]

#define SORT_CRITERIA_VALUE_ARRAY @[@"fmodified", @"dsubject", @"application"]

#define TYPE_TITLE_ARRAY @[@"Filter_View_Type_Title_Array_All_Types".localized, @"Filter_View_Type_Title_Array_Sign_Requests".localized, @"Filter_View_Type_Title_Array_Approval_Requests".localized, @"Filter_View_Type_Title_Array_Validated".localized, @"Filter_View_Type_Title_Array_Not_Validated".localized]

#define TYPE_FILTER_VALUE_ARRAY @[@"view_all", @"view_sign", @"view_pass", @"view_validate" , @"view_no_validate"]

#define TIME_INTERVAL_TITLE_ARRAY @[@"Filter_View_Time_Interval_Title_Array_All".localized, @"Filter_View_Time_Interval_Title_Array_Last_24_Hours".localized, @"Filter_View_Time_Interval_Title_Array_Last_Week".localized, @"Filter_View_Time_Interval_Title_Array_Last_Month".localized, @"Filter_View_Time_Interval_Title_Array_January".localized, @"Filter_View_Time_Interval_Title_Array_February".localized, @"Filter_View_Time_Interval_Title_Array_March".localized, @"Filter_View_Time_Interval_Title_Array_April".localized, @"Filter_View_Time_Interval_Title_Array_May".localized, @"Filter_View_Time_Interval_Title_Array_June".localized, @"Filter_View_Time_Interval_Title_Array_July".localized, @"Filter_View_Time_Interval_Title_Array_August".localized, @"Filter_View_Time_Interval_Title_Array_September".localized, @"Filter_View_Time_Interval_Title_Array_October".localized, @"Filter_View_Time_Interval_Title_Array_November".localized, @"Filter_View_Time_Interval_Title_Array_December".localized ]

#define TIME_INTERVAL_VALUE_ARRAY @[@"all", @"last24Hours", @"lastWeek", @"lastMonth", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"]

#define TIME_INTERVAL_MONTH_VALUES_ARRAY @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"]

typedef NS_ENUM (NSInteger,RequestTypeTitles) {
    RequestTypeTitleAll,
    RequestTypeTitleSign,
    RequestTypeTitleApproval,
    RequestTypeTitleValidated,
    RequestTypeTitleNotValidated
};

static const CGFloat kFilterVCPickerHeight = 30.f;
static const CGFloat kFilterVCToolBarHeight = 44.f;
static const CGFloat kFilterVCDefaultMargin = 14.f;

@interface FiltersView () {
    UITextField *_currentTextField;
}

@property (nonatomic, strong) IBOutlet UIButton *sortButton;
@property (nonatomic, strong) IBOutlet UIPickerView *sortPickerView;
@property (nonatomic, strong) IBOutlet UITextField *topicTextField;
@property (nonatomic, strong) IBOutlet UIButton *appButton;
@property (nonatomic, strong) IBOutlet UIPickerView *appPickerView;
@property (nonatomic, strong) IBOutlet UIButton *typeButton;
@property (nonatomic, strong) IBOutlet UIPickerView *typePickerView;
@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (weak, nonatomic) IBOutlet UIView *timeFilterView;
@property (nonatomic, strong) IBOutlet UIButton *timeIntervalButton;
@property (nonatomic, strong) IBOutlet UIPickerView *timeIntervalPickerView;
@property (nonatomic, strong) IBOutlet UIButton *yearButton;
@property (weak, nonatomic) IBOutlet UIView *yearView;
@property (nonatomic, strong) IBOutlet UIPickerView *yearPickerView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UISwitch *enableFiltersSwitch;
@property (weak, nonatomic) IBOutlet UIView *notificationContainerView;
@property (nonatomic, strong) IBOutlet UILabel *notificationTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *notificationStateLabel;
@property (nonatomic, strong) IBOutlet UIView *notificationSeparatorView;
@property (nonatomic, strong) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIView *roleContainerView;
@property (weak, nonatomic) IBOutlet UILabel *roleTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *roleSeparatorView;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UIButton *roleButton;
@property (weak, nonatomic) IBOutlet UILabel *selectedRoleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedRoleLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) NSString *selectedSort;
@property (weak, nonatomic) NSString *selectedApp;
@property (weak, nonatomic) NSString *selectedType;
@property (weak, nonatomic) NSString *selectedTimeInterval;
@property (weak, nonatomic) NSString *selectedYear;
@property (weak, nonatomic) IBOutlet UIButton *configurationButton;

@end

@implementation FiltersView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self listenNotificationAboutPushNotifications];
    self.backgroundColor = [UIColor greenColor];
    [self setPreviousSelectedFiltersByUser];
    [self showTimeFiltersIfNeeded];
    [self showNotificationSectionIfNeeded];
    [self showNotificationSectionState];
    [self showChangeRoleOptionIfNeeded];
    [self setFooterStyle];
    [_yearView setHidden:YES];
    [_typeView setHidden:![[NSUserDefaults standardUserDefaults]boolForKey:kPFUserDefaultsKeyUserConfigurationCompatible]];
    [self setupPickers];
    [self setFiltersSwitch];
}

#pragma mark - User Interface

- (void)hidePickers {
    [_sortPickerView setAlpha:0];
    [_appPickerView setAlpha:0];
    [_typePickerView setAlpha:0];
    [_timeIntervalPickerView setAlpha:0];
    [_yearPickerView setAlpha:0];
}

- (void) setupPickers {
    [QuartzUtils drawShadowInView:_sortPickerView];
    [QuartzUtils drawShadowInView:_appPickerView];
    [QuartzUtils drawShadowInView:_typePickerView];
    [QuartzUtils drawShadowInView:_timeIntervalPickerView];
    [QuartzUtils drawShadowInView:_yearPickerView];
    [self initDefaultPickerValues];
}

-(void) initDefaultPickerValues {
    if ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterSortCriteria]) {
        NSInteger sortCriteriaArrayPosition = [SORT_CRITERIA_VALUE_ARRAY indexOfObject: [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterSortCriteria]];
        [_sortButton setTitle:SORT_CRITERIA_TITLE_ARRAY[sortCriteriaArrayPosition] forState:UIControlStateNormal];
        _selectedSort = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterSortCriteria];
    } else {
        [_sortButton setTitle:@"Filter_View_Sort_Criteria_Default_Title".localized forState:UIControlStateNormal];
        _selectedSort = kEmptyString;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp]) {
        [_appButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp] forState:UIControlStateNormal];
        _selectedApp = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp];
    } else {
        [_appButton setTitle:@"Filter_View_Application_Default_Title".localized forState:UIControlStateNormal];
        _selectedApp = kEmptyString;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterType]) {
        [self setTypeTitleAndFilterValue: [TYPE_FILTER_VALUE_ARRAY indexOfObject: [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterType]]];
    } else if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey] isEqualToString:kUserRoleRoleNameValidator]) {
        [self setTypeTitleAndFilterValue: RequestTypeTitleNotValidated];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserHasValidator]) {
        [self setTypeTitleAndFilterValue: RequestTypeTitleValidated];
    } else {
        [self setTypeTitleAndFilterValue: RequestTypeTitleAll];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval]) {
        NSInteger timeIntervalArrayPosition = [TIME_INTERVAL_VALUE_ARRAY indexOfObject: [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval]];
        [_timeIntervalButton setTitle: [TIME_INTERVAL_TITLE_ARRAY objectAtIndex:timeIntervalArrayPosition] forState:UIControlStateNormal];
        _selectedTimeInterval = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval];
    } else {
        _selectedTimeInterval = kEmptyString;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterYear]) {
        [_yearButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterYear] forState:UIControlStateNormal];
        [_yearView setHidden:![self showYearViewWithInterval:[[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval]]];
        _selectedYear = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterYear];
    } else {
        [_yearButton setTitle:[PFHelper getCurrentYear] forState:UIControlStateNormal];
        _selectedYear = [PFHelper getCurrentYear];
    }
}

- (void)setPreviousSelectedFiltersByUser {
    _topicTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterSubject];
    _selectedApp = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp];
    _selectedType = [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterType];
}

- (void) setTypeTitleAndFilterValue: (NSInteger)selection {
    [_typeButton setTitle:TYPE_TITLE_ARRAY[selection] forState:UIControlStateNormal];
    _selectedType = TYPE_FILTER_VALUE_ARRAY[selection];
}

- (BOOL) showYearViewWithInterval: (NSString*)interval {
    return [TIME_INTERVAL_MONTH_VALUES_ARRAY containsObject: interval];
}

-(void)showTimeFiltersIfNeeded {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kPFUserDefaultsKeyUserConfigurationCompatible]) {
        [_timeFilterView setHidden: NO];
    } else {
        [_timeFilterView setHidden: YES];
    }
}

- (void) showNotificationSectionIfNeeded {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kPFUserDefaultsKeyUserConfigurationCompatible]) {
        [_notificationContainerView setHidden:![[NSUserDefaults standardUserDefaults]boolForKey:kPFUserDefaultsKeyPortafirmasNotificationsActivated]];
    } else {
        [_notificationContainerView setHidden:NO];
    }
}

- (void) showChangeRoleOptionIfNeeded {
    self.roleTitleLabel.text = @"User_Roles_Title".localized;
    self.roleLabel.text = @"User_Roles_Change_Role".localized;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoles]) {
        [_roleContainerView setHidden:NO];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected]) {
            self.selectedRoleNameLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleUserNameKey] objectForKey:kContentKey];
            self.selectedRoleLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey];
        } else {
            self.selectedRoleNameLabel.hidden = YES;
            self.selectedRoleLabel.text = @"User_Role_Signer".localized;
        }
    } else {
        [_roleContainerView setHidden:YES];
    }
}

- (void)setFiltersSwitch {
    [_enableFiltersSwitch setOn:NO];
    if (([[NSUserDefaults standardUserDefaults]objectForKey:kPFUserDefaultsKeyUserSelectionFilterSubject] != nil &&
         ![[[NSUserDefaults standardUserDefaults]objectForKey:kPFUserDefaultsKeyUserSelectionFilterSubject] isEqualToString:kEmptyString]) ||
        ([[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp] != nil &&
         ![[[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterApp] isEqualToString:kEmptyString]) ||
        [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterType] != nil ||
        [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval] != nil ||
        [[NSUserDefaults standardUserDefaults] objectForKey: kPFUserDefaultsKeyUserSelectionFilterYear]
        ) {
        [_enableFiltersSwitch setOn:YES];
        [self enableFiltersButtons: YES];
    } else {
        [_enableFiltersSwitch setOn:NO];
        [self enableFiltersButtons: NO];
    }
}

- (void)setFooterStyle {
    [_footerView setBackgroundColor: BACKGROUND_COLOR_GRAY_FOR_TOOLBAR];
    [_acceptButton setTitle:@"Filter_View_Footer_Accept_Button_Title".localized forState:normal];
    [_cancelButton setTitle:@"Filter_View_Footer_Cancel_Button_Title".localized forState:normal];
    [_acceptButton setTitleColor:COLOR_FOR_RED_TEXT forState:normal];
    [_cancelButton setTitleColor:COLOR_FOR_RED_TEXT forState:normal];
}

#pragma mark - User Interaction

- (IBAction)didClickSortCriteriaButton:(id)sender {
    [self hidePickers];
    [self endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
         [self.sortPickerView setAlpha:1];
     }];
}

- (IBAction)didClickAppButton:(id)sender {
    if ([[AppListXMLController sharedInstance] appsArray] && [[AppListXMLController sharedInstance] appsArray].count > 0) {
        [self hidePickers];
        [self endEditing:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [self.appPickerView setAlpha:1];
         }];
    }
}

- (IBAction)didClickTypeButton:(id)sender {
    [self hidePickers];
    [self endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.typePickerView setAlpha:1];
    }];
}

- (IBAction)didClickIntervalButton:(id)sender {
    [self hidePickers];
    [self endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.timeIntervalPickerView setAlpha:1];
    }];
}

- (IBAction)didClickYearButton:(id)sender {
    [self hidePickers];
    [self endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.yearPickerView setAlpha:1];
    }];
}

- (IBAction)didUpdateValueForFilterSwitch:(id)sender {
    [self enableFiltersButtons:[sender isOn]];
}

- (void) enableFiltersButtons:(BOOL)enable {
    [_topicTextField setEnabled:enable];
    [_appButton setEnabled:(![[AppListXMLController sharedInstance] appsArray] || [[AppListXMLController sharedInstance] appsArray].count == 0) ? NO:enable];
    [_typeButton setEnabled:enable];
    [_timeIntervalButton setEnabled:enable];
    [_yearButton setEnabled:enable];
    [self hidePickers];
}

- (IBAction)didSelectAcceptButton:(id)sender {
    NSMutableDictionary *filters = [@{} mutableCopy];    
    if (![_selectedSort isEqualToString: kEmptyString]) {
        filters[kPFFilterKeySortCriteria] = _selectedSort;
        filters[kPFFilterKeySort] = kPFFilterValueSortDesc;
        [[NSUserDefaults standardUserDefaults] setObject:_selectedSort forKey: kPFUserDefaultsKeyUserSelectionFilterSortCriteria];
    }
    if ([_enableFiltersSwitch isOn]) {
        if (_topicTextField.text && _topicTextField.text.length > 0) {
            filters[kPFFilterKeySubject] = _topicTextField.text;
        }
        [[NSUserDefaults standardUserDefaults] setObject:_topicTextField.text forKey: kPFUserDefaultsKeyUserSelectionFilterSubject];
        if (![_selectedApp isEqualToString: kEmptyString] && ![_selectedApp isEqualToString: @"Filter_View_Application_Default_All_Title".localized]) {
            filters[kPFFilterKeyApp] = _selectedApp;
            [[NSUserDefaults standardUserDefaults] setObject:_selectedApp forKey: kPFUserDefaultsKeyUserSelectionFilterApp];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject: nil forKey: kPFUserDefaultsKeyUserSelectionFilterApp];
        }
        if (![_selectedType isEqualToString: kEmptyString]) {
            filters[kPFFilterKeyType] = _selectedType;
        }
        [[NSUserDefaults standardUserDefaults] setObject:_selectedType forKey: kPFUserDefaultsKeyUserSelectionFilterType];
        if (![_selectedTimeInterval isEqualToString: kEmptyString]) {
            filters[kFilterKeyMonth] = _selectedTimeInterval;
            [[NSUserDefaults standardUserDefaults] setObject:_selectedTimeInterval forKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject: nil forKey: kPFUserDefaultsKeyUserSelectionFilterTimeInterval];
        }
        if (![_selectedYear isEqualToString: kEmptyString] && [self showYearViewWithInterval:_selectedTimeInterval]) {
            filters[kFilterKeyYear] = _selectedYear;
            [[NSUserDefaults standardUserDefaults] setObject:_selectedYear forKey: kPFUserDefaultsKeyUserSelectionFilterYear];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey: kPFUserDefaultsKeyUserSelectionFilterYear];
        }
    }
    [self.filtersViewDelegate didSelectAcceptButton: filters];
}

- (IBAction)didSelectCancelButton:(id)sender {
    [self.filtersViewDelegate didSelectCancelButton];
}

- (IBAction)didSelectConfirmationButton:(id)sender {
    DefaultNavigationViewController *nvc = [[DefaultNavigationViewController alloc] init];
    ConfigurationViewController *vc = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationView" bundle:nil];
    ConfigurationViewModel *viewModel = [[ConfigurationViewModel alloc] init];
    [vc injectViewModelWithViewModel:viewModel];
    [nvc initWithRootViewController:vc];
    UIViewController *currentTopVC = [self currentTopViewController];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [currentTopVC presentViewController:nvc animated:YES completion:nil];
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

#pragma mark - Notifications Section

- (void) showNotificationSectionState {
    self.notificationStateLabel.text = [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserNotificationsActivated] ? @"Filter_View_Push_Notification_Enabled_Title".localized : @"Filter_View_Push_Notification_Pending_Title".localized;
    [self.notificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserNotificationsActivated]? YES : NO];
}

-(IBAction)switchChanged:(UISwitch *)sender {
    self.notificationStateLabel.text = [self.notificationSwitch isOn] ? @"Filter_View_Push_Notification_Enabled_Title".localized : @"Filter_View_Push_Notification_Pending_Title".localized;
    if([self.notificationSwitch isOn]){
        [self initSubscriptionProcess];
    } else {
        if([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserConfigurationCompatible] && [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyPortafirmasNotificationsActivated]){
            [self initUnsubscriptionProcess];
        }
    }
}

- (void) initSubscriptionProcess {
    [[PushNotificationService instance] initializePushNotificationsService:true];
}

- (void) initUnsubscriptionProcess {
    [[PushNotificationService instance] unsubscribe];
}

- (void) listenNotificationAboutPushNotifications {
    [self removeNotificationAboutPushNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishSubscriptionProcess)
                                                 name:@"FinishSubscriptionProcessNotification"
                                               object:nil];
}

- (void) removeNotificationAboutPushNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishSubscriptionProcessNotification" object:nil];
}

- (void) finishSubscriptionProcess {
    [self showNotificationSectionState];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        return SORT_CRITERIA_TITLE_ARRAY.count;
    } else if ([pickerView isEqual:_appPickerView]) {
        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray].count : 0;
    } else if ([pickerView isEqual:_typePickerView]) {
        return TYPE_TITLE_ARRAY.count;
    } else if ([pickerView isEqual:_timeIntervalPickerView]) {
        return TIME_INTERVAL_TITLE_ARRAY.count;
    } else if ([pickerView isEqual:_yearPickerView]) {
        return [PFHelper getYearsForFilter].count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        return SORT_CRITERIA_TITLE_ARRAY[row];
    } else if ([pickerView isEqual:_appPickerView]) {
        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray][row] : nil;
    } else if ([pickerView isEqual:_typePickerView]) {
        return TYPE_TITLE_ARRAY[row];
    } else if ([pickerView isEqual:_timeIntervalPickerView]) {
        return TIME_INTERVAL_TITLE_ARRAY[row];
    } else if ([pickerView isEqual:_yearPickerView]) {
        return [PFHelper getYearsForFilter][row];
    }
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kFilterVCPickerHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        [_sortButton setTitle:SORT_CRITERIA_TITLE_ARRAY[row] forState:UIControlStateNormal];
        [_sortButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedSort = SORT_CRITERIA_VALUE_ARRAY[row] ;
    } else if ([pickerView isEqual:_appPickerView]) {
        [_appButton setTitle:[[AppListXMLController sharedInstance] appsArray][row] forState:UIControlStateNormal];
        [_appButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedApp = [[AppListXMLController sharedInstance] appsArray][row];
    } else if ([pickerView isEqual:_typePickerView]) {
        [_typeButton setTitle:TYPE_TITLE_ARRAY[row] forState:UIControlStateNormal];
        [_typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedType = TYPE_FILTER_VALUE_ARRAY[row];
    }  else if ([pickerView isEqual:_timeIntervalPickerView]) {
        [_timeIntervalButton setTitle: TIME_INTERVAL_TITLE_ARRAY[row] forState:UIControlStateNormal];
        [_timeIntervalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedTimeInterval = TIME_INTERVAL_VALUE_ARRAY[row];
        [_yearView setHidden:![self showYearViewWithInterval:TIME_INTERVAL_VALUE_ARRAY[row]]];
        _selectedYear = [PFHelper getCurrentYear];
    }  else if ([pickerView isEqual:_yearPickerView]) {
        [_yearButton setTitle: [PFHelper getYearsForFilter][row] forState:UIControlStateNormal];
        [_yearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedYear = [PFHelper getYearsForFilter][row];
    }
    [self performSelector:@selector(hidePickers) withObject:nil afterDelay:0.5];
}

#pragma mark - User Role

- (IBAction)tapChangeRole:(id)sender {
    [self.filtersViewDelegate tapChangeRole];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentTextField = textField;
    if ([_currentTextField isEqual:_topicTextField]) {
        [self hidePickers];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
