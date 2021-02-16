//
//  FiltersView.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 15/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FiltersViewDelegate <NSObject>
- (void)tapChangeRole;
- (void)didSelectAcceptButton: (NSMutableDictionary *) selectedFilters;
- (void)didSelectCancelButton;
@end

@interface FiltersView : UIView <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
- (IBAction)switchChanged:(UISwitch *)sender;

- (void) showChangeRoleOptionIfNeeded;

@property (nonatomic, weak) id <FiltersViewDelegate> filtersViewDelegate;

@end
