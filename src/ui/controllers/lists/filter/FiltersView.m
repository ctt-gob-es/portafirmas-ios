//
//  FiltersView.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FiltersView.h"
#import "GlobalConstants.h"
#import "AppListXMLController.h"

#define SORT_CRITERIA_ARRAY @[@"Filter_View_Sort_Criteria_Array_Date".localized, @"Filter_View_Sort_Criteria_Array_Topic".localized, @"Filter_View_Sort_Criteria_Array_Application".localized]

#define TYPE_TITLE_ARRAY @[@"Filter_View_Type_Title_Array_All_Types".localized, @"Filter_View_Type_Title_Array_Sign_Requests".localized, @"Filter_View_Type_Title_Array_Approval_Requests".localized, @"Filter_View_Type_Title_Array_Validated".localized, @"Filter_View_Type_Title_Array_Not_Validated".localized]

#define TYPE_FILTER_VALUE_ARRAY @[@"view_all", @"view_sign", @"view_pass", @"view_validate" , @"view_no_validate"]

#define TIME_INTERVAL_TITLE_ARRAY @[@"Filter_View_Time_Interval_Title_Array_All".localized, @"Filter_View_Time_Interval_Title_Array_Last_24_Hours".localized, @"Filter_View_Time_Interval_Title_Array_Last_Week".localized, @"Filter_View_Time_Interval_Title_Array_Last_Month".localized, @"Filter_View_Time_Interval_Title_Array_January".localized, @"Filter_View_Time_Interval_Title_Array_February".localized, @"Filter_View_Time_Interval_Title_Array_March".localized, @"Filter_View_Time_Interval_Title_Array_April".localized, @"Filter_View_Time_Interval_Title_Array_May".localized, @"Filter_View_Time_Interval_Title_Array_June".localized, @"Filter_View_Time_Interval_Title_Array_July".localized, @"Filter_View_Time_Interval_Title_Array_August".localized, @"Filter_View_Time_Interval_Title_Array_September".localized, @"Filter_View_Time_Interval_Title_Array_October".localized, @"Filter_View_Time_Interval_Title_Array_November".localized, @"Filter_View_Time_Interval_Title_Array_December".localized ]

#define TIME_INTERVAL_VALUE_ARRAY @[@"all", @"last24Hours", @"lastWeed", @"lastMonth", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"]

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
@property (nonatomic, strong) IBOutlet UIButton *timeIntervalButton;
@property (nonatomic, strong) IBOutlet UIPickerView *timeIntervalPickerView;
@property (nonatomic, strong) IBOutlet UIButton *yearButton;
@property (weak, nonatomic) IBOutlet UIView *yearView;
@property (nonatomic, strong) IBOutlet UIPickerView *yearPickerView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UISwitch *enableFiltersSwitch;
@property (nonatomic, strong) IBOutlet UILabel *notificationTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *notificationStateLabel;
@property (nonatomic, strong) IBOutlet UIView *notificationSeparatorView;
@property (nonatomic, strong) IBOutlet UISwitch *notificationSwitch;
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

@end

@implementation FiltersView
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor greenColor];
    [self showChangeRoleOptionIfNeeded];
    [self setFooterStyle];
    [_yearView setHidden:YES];
    [self setupPickers];
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
    _selectedSort = kEmptyString;
    _selectedApp = kEmptyString;
    _selectedType = kEmptyString;
    _selectedTimeInterval = kEmptyString;
    _selectedYear = kEmptyString;
    [_sortButton setTitle:@"Filter_View_Sort_Criteria_Default_Title".localized forState:UIControlStateNormal];
    [_appButton setTitle:@"Filter_View_Application_Default_Title".localized forState:UIControlStateNormal];
    if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey] isEqualToString:kUserRoleRoleNameValidator]) {
        [self setTypeTitleAndFilterValue: RequestTypeTitleNotValidated];
    } else {
        [self setTypeTitleAndFilterValue: RequestTypeTitleAll];
    }
}

- (void) setTypeTitleAndFilterValue: (NSInteger)selection {
    [_typeButton setTitle:TYPE_TITLE_ARRAY[selection] forState:UIControlStateNormal];
    _selectedType = TYPE_FILTER_VALUE_ARRAY[selection];
}

- (BOOL) showYearViewWithInterval: (NSString*)interval {
    return [TIME_INTERVAL_MONTH_VALUES_ARRAY containsObject: interval];
}

- (void) showChangeRoleOptionIfNeeded {
    self.roleTitleLabel.text = @"User_Roles_Title".localized;
    self.roleLabel.text = @"User_Roles_Change_Role".localized;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoles]) {
        self.roleTitleLabel.hidden = NO;
        self.roleSeparatorView.hidden = NO;
        self.roleLabel.hidden = NO;
        self.roleButton.hidden = NO;
        self.selectedRoleNameLabel.hidden = NO;
        self.selectedRoleLabel.hidden = NO;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected]) {
            self.selectedRoleNameLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleUserNameKey] objectForKey:kContentKey];
            self.selectedRoleLabel.text =[[[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected] objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey];
        } else {
            self.selectedRoleNameLabel.hidden = YES;
            self.selectedRoleLabel.text = @"User_Role_Signer".localized;
        }
    } else {
        self.roleTitleLabel.hidden = YES;
        self.roleSeparatorView.hidden = YES;
        self.roleLabel.hidden = YES;
        self.roleButton.hidden = YES;
        self.selectedRoleNameLabel.hidden = YES;
        self.selectedRoleLabel.hidden = YES;
    }
}

-(void)setFooterStyle {
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
    BOOL enable = [sender isOn];
    [_topicTextField setEnabled:enable];
    [_appButton setEnabled:(![[AppListXMLController sharedInstance] appsArray] || [[AppListXMLController sharedInstance] appsArray].count == 0) ? NO:enable];
    [_typeButton setEnabled:enable];
    [_timeIntervalButton setEnabled:enable];
    [_yearButton setEnabled:enable];
    [self hidePickers];
}

- (IBAction)didSelectAcceptButton:(id)sender {
    NSMutableDictionary *filters = [@{} mutableCopy];
    NSString *sortValue = [PFHelper getPFSortCriteriaValueForRow:[_sortPickerView selectedRowInComponent:0]];
    if (![_selectedSort isEqualToString: kEmptyString]) {
        filters[kPFFilterKeySortCriteria] = sortValue;
        filters[kPFFilterKeySort] = kPFFilterValueSortDesc;
    }
    if ([_enableFiltersSwitch isOn]) {
        if (_topicTextField.text && _topicTextField.text.length > 0) {
            filters[kPFFilterKeySubject] = _topicTextField.text;
        }
        if (![_selectedApp isEqualToString: kEmptyString]) {
            filters[kPFFilterKeyApp] = _selectedApp;
        }
        if (![_selectedType isEqualToString: kEmptyString]) {
            filters[kFilterTypeKey] = _selectedType;
        }
    }
    [self.filtersViewDelegate didSelectAcceptButton: filters];
}

- (IBAction)didSelectCancelButton:(id)sender {
    [self.filtersViewDelegate didSelectCancelButton];
}

#pragma mark - Notifications Section

-(IBAction)switchChanged:(UISwitch *)sender {
//
//    if([self.notificationSwitch isOn]){
//        [self initSubscriptionProcess];
//    } else {
//        [self showNotificationSectionState];
//    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        return SORT_CRITERIA_ARRAY.count;
    } else if ([pickerView isEqual:_appPickerView]) {
        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray].count : 0;
    } else if ([pickerView isEqual:_typePickerView]) {
        return TYPE_TITLE_ARRAY.count;
    } else if ([pickerView isEqual:_timeIntervalPickerView]) {
        return TIME_INTERVAL_TITLE_ARRAY.count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        return SORT_CRITERIA_ARRAY[row];
    } else if ([pickerView isEqual:_appPickerView]) {
        return [[AppListXMLController sharedInstance] appsArray] ? [[AppListXMLController sharedInstance] appsArray][row] : nil;
    } else if ([pickerView isEqual:_typePickerView]) {
        return TYPE_TITLE_ARRAY[row];
    } else if ([pickerView isEqual:_timeIntervalPickerView]) {
        return TIME_INTERVAL_TITLE_ARRAY[row];
    }
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kFilterVCPickerHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:_sortPickerView]) {
        [_sortButton setTitle:SORT_CRITERIA_ARRAY[row] forState:UIControlStateNormal];
        [_sortButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectedSort = SORT_CRITERIA_ARRAY[row] ;
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
        [self.yearView setHidden:![self showYearViewWithInterval:TIME_INTERVAL_VALUE_ARRAY[row]]];
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
