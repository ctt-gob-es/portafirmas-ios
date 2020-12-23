//
//  FilterVC.h
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 11/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterVC : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

- (IBAction)switchChanged:(UISwitch *)sender;
- (IBAction)tapChangeRole:(id)sender;

@end
