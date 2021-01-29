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

#define SORT_CRITERIA_ARRAY @[@"Fecha", @"Asunto", @"Aplicación"]
#define TYPE_ARRAY @[@"Filter_View_Type_Array_All_Types".localized, @"Filter_View_Type_Array_Sign_Requests".localized, @"Filter_View_Type_Array_Approval_Requests".localized, @"Filter_View_Type_Array_Validated".localized , @"Filter_View_Type_Array_Not_Validated".localized]

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

@end

@implementation FiltersView
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor greenColor];
    [self showChangeRoleOptionIfNeeded];
    [self setFooterStyle];
    [self setupPickers];
}

#pragma mark - User Interface

- (void)hidePickers {
    [_sortPickerView setAlpha:0];
    [_appPickerView setAlpha:0];
    [_typePickerView setAlpha:0];
}

- (void) setupPickers {
    [QuartzUtils drawShadowInView:_sortPickerView];
    [QuartzUtils drawShadowInView:_appPickerView];
    [QuartzUtils drawShadowInView:_typePickerView];
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

- (IBAction)didUpdateValueForFilterSwitch:(id)sender {
    BOOL enable = [sender isOn];
    [_topicTextField setEnabled:enable];
    [_appButton setEnabled:(![[AppListXMLController sharedInstance] appsArray] || [[AppListXMLController sharedInstance] appsArray].count == 0) ? NO:enable];
    [_typeButton setEnabled:enable];
    [self hidePickers];
}

- (IBAction)didSelectAcceptButton:(id)sender {
    NSMutableDictionary *filters = [@{} mutableCopy];
    if ([_enableFiltersSwitch isOn]) {
        if (_topicTextField.text && _topicTextField.text.length > 0) {
            filters[kPFFilterKeySubject] = _topicTextField.text;
        }
    }
    if (![_sortButton.titleLabel.text isEqualToString:@"Selecciona un criterio de ordenación"]) {
        NSString *sortValue = [PFHelper getPFSortCriteriaValueForRow:[_sortPickerView selectedRowInComponent:0]];
        if (sortValue) {
            filters[kPFFilterKeySortCriteria] = sortValue;
            filters[kPFFilterKeySort] = kPFFilterValueSortDesc;
        }
    }
    if (![_appButton.titleLabel.text isEqualToString:@"Selecciona una aplicación"]) {
        filters[kPFFilterKeyApp] = [[AppListXMLController sharedInstance] appsArray][[_appPickerView selectedRowInComponent:0]];
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
        return TYPE_ARRAY.count;
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
        return TYPE_ARRAY[row];
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
    } else if ([pickerView isEqual:_appPickerView]) {
        [_appButton setTitle:[[AppListXMLController sharedInstance] appsArray][row] forState:UIControlStateNormal];
        [_appButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else if ([pickerView isEqual:_typePickerView]) {
        [_typeButton setTitle:TYPE_ARRAY[row] forState:UIControlStateNormal];
        [_typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
