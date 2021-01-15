//
//  FiltersView.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FiltersView.h"

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

@end

@implementation FiltersView
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor greenColor];
}

@end
