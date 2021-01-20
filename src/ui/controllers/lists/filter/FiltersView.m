//
//  FiltersView.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FiltersView.h"

#define SORT_CRITERIA_ARRAY @[@"Fecha", @"Asunto", @"Aplicación"]

static const CGFloat kFilterVCPickerHeight = 30.f;
static const CGFloat kFilterVCToolBarHeight = 44.f;
static const CGFloat kFilterVCDefaultMargin = 14.f;

@interface FiltersView ()

@property (nonatomic, strong) IBOutlet UIButton *sortButton;
@property (nonatomic, strong) IBOutlet UIPickerView *sortPickerView;
@property (nonatomic, strong) IBOutlet UITextField *topicTextField;
@property (nonatomic, strong) IBOutlet UIButton *appButton;
@property (nonatomic, strong) IBOutlet UIPickerView *appPickerView;
@property (nonatomic, strong) IBOutlet UITextField *startDateTextField;
@property (nonatomic, strong) IBOutlet UITextField *endDateTextField;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
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
    [self setFooterStyle];
}

#pragma mark - User Interface

-(void)setFooterStyle {
    [_footerView setBackgroundColor: BACKGROUND_COLOR_GRAY_FOR_TOOLBAR];
    [_acceptButton setTitle:@"Filter_View_Footer_Accept_Button_Title".localized forState:normal];
    [_cancelButton setTitle:@"Filter_View_Footer_Cancel_Button_Title".localized forState:normal];
    [_acceptButton setTitleColor:COLOR_FOR_RED_TEXT forState:normal];
    [_cancelButton setTitleColor:COLOR_FOR_RED_TEXT forState:normal];
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

//#pragma mark - Keyboard Notifications

#pragma mark - User Role

- (IBAction)tapChangeRole:(id)sender {
    [self.tapChangeRoleDelegateDelegate tapChangeRole];
}

@end
