 //
//  SettingsVC.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 16/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "SettingsVC.h"
#import "SettingsCell.h"
#import "CertificateUtils.h"
#import "AppListXMLController.h"
#import "LoginService.h"
#import "PFError.h"
#import "ErrorService.h"

static const NSInteger kSettingsVCNumberOfSections = 2;
static const NSInteger kSettingsVCNumberOfRowsPerSection = 1;
static NSString *const kSettingsVCSectionTitleServerURL = @"Servidor";
static NSString *const kSettingsVCSectionTitleCertificate = @"Certificado";
static NSString *const kSettingsVCCellIdentifier = @"SettingsCell";
static NSString *const kSettingsVCSegueIdentifierServerURLs = @"showServerListVC";
static NSString *const kSettingsVCSegueIdentifierCertificates = @"showRegisteredCertificates";
static NSString *const kSettingsVCSegueIdentifierAccess = @"showRequests";

typedef NS_ENUM (NSInteger, SettingsVCSection)
{
    SettingsVCSectionServerURL,
    SettingsVCSectionCertificate
};


@interface SettingsVC ()
{
    NSString *_currentCertificate;
    NSArray *userDefaultsKeys;
}

@property (nonatomic, strong) IBOutlet UIButton *accessButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleBar;

@end

@implementation SettingsVC

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.titleBar.title =[NSString stringWithFormat: NSLocalizedString(@"Configuration_Page_Title", nil),[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateAccessButton];
}

#pragma mark - User Interface

- (void)updateAccessButton
{

    userDefaultsKeys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys;
    
    [_accessButton setEnabled: [userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentServer]];
}

#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSettingsVCNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kSettingsVCNumberOfRowsPerSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SettingsVCSectionServerURL:
            return kSettingsVCSectionTitleServerURL;
        case SettingsVCSectionCertificate:
            return kSettingsVCSectionTitleCertificate;
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSettingsVCCellIdentifier];
    
    if (!cell) {
		return nil;
    }
    
    [cell setupForType:indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *segueIdentifier;
    
    switch (indexPath.section) {
            
        case SettingsVCSectionServerURL:
            segueIdentifier = kSettingsVCSegueIdentifierServerURLs;
            break;
            
        case SettingsVCSectionCertificate:
            segueIdentifier = kSettingsVCSegueIdentifierCertificates;
            break;
    }
    
    if (segueIdentifier) {
        
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

#pragma mark - Navigation Methods
    
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    __block BOOL segue = NO;
    if ([identifier isEqualToString:kSettingsVCSegueIdentifierAccess]) {
        
        [[LoginService instance] loginWithCertificate:^{
            segue = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:identifier sender:self];
            });
         } failure:^(NSError *error) {
             if (error != nil && error.code == PFLoginNotSupported) {
                 segue = YES;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self performSegueWithIdentifier:identifier sender:self];
                 });
             } else {
                 segue = NO;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[ErrorService instance] showLoginErrorAlertView];
                 });  
             }
         }];
    } else {
        segue = YES;
    }

    return segue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:kSettingsVCSegueIdentifierAccess]) {
        
        if (![userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate]) {
                
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No tiene certificado asociado al Portafirmas seleccionado."
                                                                                        message:@"Por favor, seleccione uno para continuar."
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Aceptar"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        else {
            [self prepareForAccessSegue:segue];
        }
    }
}

- (void)prepareForAccessSegue:(UIStoryboardSegue *)segue
{
    [[AppListXMLController sharedInstance] requestAppsList];
}

#pragma mark - ServerListTVCDelegate

- (void)serverListDidSelectServer:(NSDictionary *)serverInfo
{
    [self.tableView reloadData];
}

@end
