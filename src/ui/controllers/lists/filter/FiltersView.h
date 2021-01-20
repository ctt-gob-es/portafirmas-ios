//
//  FiltersView.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapChangeRoleDelegate <NSObject>
- (void)tapChangeRole;
@end

@interface FiltersView : UIView <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
- (IBAction)switchChanged:(UISwitch *)sender;

@property (nonatomic, weak) id <TapChangeRoleDelegate> tapChangeRoleDelegateDelegate;

@end
