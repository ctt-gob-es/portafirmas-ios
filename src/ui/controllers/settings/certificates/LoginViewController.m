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
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    // Load certificate from Documents directory
    status = [OpenSSLCertificateHelper deleteCertificate:certificateInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

    return status;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.editButtonItem setEnabled:[arrayCerts count] > 0];
    return [arrayCerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CertificateCell";
    CertificateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
                    _infoLabel = @"Certificate_Removed_Correctly".localized;
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyCurrentCertificate];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[CertificateUtils sharedWrapper] setSelectedCertificateName:nil];
        
                    break;
                default:
                    _infoLabel = @"Alert_View_An_Error_Has_Ocurred".localized;
                    break;
            }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:_infoLabel message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle: @"Ok".localized
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:actionOk];
        [self presentViewController:alert animated:YES completion:nil];
        
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
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    PFCertificateInfo *selectedCertificate = arrayCerts[selectedIndexPath.row];
    
    if ([[CertificateUtils sharedWrapper] searchIdentityByName:selectedCertificate.subject] == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:@{kPFUserDefaultsKeyAlias:selectedCertificate.subject} forKey:kPFUserDefaultsKeyCurrentCertificate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[CertificateUtils sharedWrapper] setSelectedCertificateName:selectedCertificate.subject];
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Alert_View_Error_When_Loading_certificate".localized
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Ok".localized style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end

