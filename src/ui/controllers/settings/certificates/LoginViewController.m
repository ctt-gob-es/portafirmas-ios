//
//  LoginViewController.m
//  pruebasVarias
//
//  Created by Luis Lopez on 18/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CertificateUtils.h"
#import "CertificateCell.h"
#import "OpenSSLCertificateHelper.h"

@interface LoginViewController ()
{
    NSMutableArray *arrayCerts;
    NSDictionary *dictionary;
    NSUserDefaults *settings;
}

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editBarButtonItem;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setToolbarHidden:YES];

    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadCertificates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    arrayCerts = nil;
    [super viewDidUnload];
}

#pragma mark - User Interface

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Certificates

- (void)reloadCertificates
{
    arrayCerts = nil;
    arrayCerts = [[OpenSSLCertificateHelper getAddedCertificatesInfo] mutableCopy];
    

    if (!arrayCerts) {
        arrayCerts = [[NSMutableArray alloc] init];
    }
}

// Unregister certificate with name
- (OSStatus)deleteCertificate:(PFCertificateInfo *)certificateInfo
{
    OSStatus status = noErr;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    // Load certificate from Documents directory
    status = [OpenSSLCertificateHelper deleteCertificate:certificateInfo];
    [SVProgressHUD dismiss];

    if (status == noErr) {
        //T21LogDebug(@"deleterWithCertificateName::Certificate %@ is deleted from keychain:", certificateInfo.subject);
    }
    else {
        //T21LogDebug(@"deleterWithCertificateName::Certificate %@ is deleted from keychain:", certificateInfo.subject);
        //T21LogDebug(@"No Se ha eliminado el certificado correctamente.Error: %i", (int)status);
    }

    return status;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //T21LogDebug(@"LoginViewController::numberOfRowsInSection=%ld. rows=%ld", (long)section, (unsigned long)[arrayCerts count]);
    [self.editButtonItem setEnabled:[arrayCerts count] > 0];

    return [arrayCerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //T21LogDebug(@"LoginViewController::cellForRowAtIndexPath row=%ld", (long)[indexPath row]);

    static NSString *CellIdentifier = @"CertificateCell";
    CertificateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        //T21LogDebugT21LogError(@"LoginViewController::cell is nill");
    }
    
    [cell setCertificateInfo:arrayCerts[indexPath.row] forEditingCell:self.isEditing];

    return cell;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Eliminar";
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.tableView beginUpdates];
        PFCertificateInfo *certificateToDelete = arrayCerts[indexPath.row];
        OSStatus status = [self deleteCertificate: certificateToDelete];
        [self.tableView endUpdates];
        NSString *_infoLabel = nil;
            switch (status) {
                case noErr :
                case errSecItemNotFound:
                    _infoLabel = @"Se ha eliminado el certificado correctamente";
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyCurrentCertificate];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[CertificateUtils sharedWrapper] setSelectedCertificateName:nil];
        
                    break;
                default:
                    _infoLabel = @"Se ha producido un error";
                    break;
            }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_infoLabel message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [self reloadCertificates];
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    PFCertificateInfo *selectedCertificate = arrayCerts[selectedIndexPath.row];
    
    //T21LogDebug(@"LoginViewController::prepareForSegue selected index=%ld", (long)selectedIndexPath.row);
    //T21LogDebug(@"LoginViewController:: certificado seleccionado -> %@", selectedCertificate.subject);
    
    if ([[CertificateUtils sharedWrapper] searchIdentityByName:selectedCertificate.subject] == YES) {
        
        //T21LogDebug(@"LoginViewController::prepareForSegue::selected certificate....");
        [[NSUserDefaults standardUserDefaults] setObject:@{kPFUserDefaultsKeyAlias:selectedCertificate.subject} forKey:kPFUserDefaultsKeyCurrentCertificate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[CertificateUtils sharedWrapper] setSelectedCertificateName:selectedCertificate.subject];
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:@"Se ha producido un error al cargar el certificado"
                                    message:@""
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end

