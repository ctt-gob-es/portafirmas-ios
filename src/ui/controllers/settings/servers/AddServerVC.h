//
//  AddServerVC.h
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 17/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

@interface AddServerVC: PFBaseVC <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, retain) IBOutlet UITextField *aliasTextField;
@property (nonatomic, retain) IBOutlet UITextField *urlTextField;

@property (nonatomic, retain) NSString *aliasReceived, *urlRecived;
@property (nonatomic, assign, getter = isEdit) BOOL isEdit;

-(void) updateSaveButton;

@end
