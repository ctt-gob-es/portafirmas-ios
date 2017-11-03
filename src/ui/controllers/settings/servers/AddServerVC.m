//
//  AddServerVC.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 17/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "AddServerVC.h"
#import "ServerListTVC.h"
#import "PFHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddServerVC

NSDictionary *typeDict;

@synthesize aliasTextField, urlTextField, aliasReceived, urlRecived, isEdit, selectedCertificate;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isEdit = NO;
    
    NSLog(@"Texto recibido Alias-> %@", aliasReceived);
    NSLog(@"URL   -> %@", urlRecived);
    
    if (aliasReceived != NULL && urlRecived != NULL) {
        
        aliasTextField.text = [[NSString alloc]init];
        urlTextField.text = [[NSString alloc]init];
        aliasTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""];
        urlTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""];
        
        aliasTextField.text = aliasReceived;
        urlTextField.text = urlRecived;
        isEdit = YES;
        [aliasTextField reloadInputViews];
        [urlTextField reloadInputViews];
    }
    
    [self appearence];
    [self updateSaveButton];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    typeDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentCertificate];
    
    NSLog(@"Diccionario -> %@", [typeDict allValues]);
    if (typeDict && [typeDict.allKeys containsObject: kPFUserDefaultsKeyAlias] && (![aliasTextField.text isEqualToString:@""] ||  ![urlTextField.text isEqualToString:@""])) {
        
        [selectedCertificate setTitle: typeDict[kPFUserDefaultsKeyAlias] forState: UIControlStateNormal];
        [selectedCertificate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [selectedCertificate reloadInputViews];
        [self updateSaveButton];
    }
    else {
        [selectedCertificate setTitle: @"Sin especificar" forState: UIControlStateNormal];
        [selectedCertificate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [selectedCertificate reloadInputViews];
        [self updateSaveButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interface

-(void) appearence {
    
    // TextField AliasTextField
    aliasTextField.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    aliasTextField.layer.borderWidth = 1.0;
    aliasTextField.layer.cornerRadius = 5;
    
    // TextField URLTextField
    urlTextField.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    urlTextField.layer.borderWidth = 1.0;
    urlTextField.layer.cornerRadius = 5;
    
    // Button
    [[selectedCertificate layer] setBorderColor: [UIColor lightGrayColor].CGColor];
    [[selectedCertificate layer] setCornerRadius: 5];
    [[selectedCertificate layer] setMasksToBounds: YES];
    [[selectedCertificate layer] setBorderWidth: 1];
    [selectedCertificate reloadInputViews];
}

- (void)updateSaveButton
{
    NSString *alias = @"";
    NSString *url = @"";
    
    if ((![aliasReceived isEqualToString:@""] & ![urlRecived isEqualToString:@""]) || ((aliasReceived == (id)[NSNull null]) && (urlRecived) == (id)[NSNull null])) {

        alias = [aliasTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        url = [urlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    [_saveBarButtonItem setEnabled:alias && alias.length > 0 && url && url.length > 0 && typeDict && [typeDict.allKeys containsObject: kPFUserDefaultsKeyAlias]];
}

#pragma mark - User Interaction

- (IBAction)didClickCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickSaveButton:(id)sender
{
    
    NSString *alias = [aliasTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = [urlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultsKeys = standardUserDefaults.dictionaryRepresentation.allKeys;
    NSMutableArray *serversArray = [[defaultsKeys containsObject:kPFUserDefaultsKeyServersArray] ? [standardUserDefaults arrayForKey:kPFUserDefaultsKeyServersArray] : @[] mutableCopy];
    
    if (isEdit ) {
        for (int i = 0; i < [serversArray count]; i++) {
            if ([[serversArray objectAtIndex: i] containsObject: aliasReceived]) {
                [serversArray removeObjectAtIndex: i];
            }
        }
        
        [serversArray addObject:@{kPFUserDefaultsKeyAlias:alias, kPFUserDefaultsKeyURL:url}];
        [[NSUserDefaults standardUserDefaults] setObject:serversArray forKey:kPFUserDefaultsKeyServersArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
     
        [serversArray addObject:@{kPFUserDefaultsKeyAlias:alias, kPFUserDefaultsKeyURL:url}];
        [[NSUserDefaults standardUserDefaults] setObject:serversArray forKey:kPFUserDefaultsKeyServersArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldDidChange:(id)sender
{
    [self updateSaveButton];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
