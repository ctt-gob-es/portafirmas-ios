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

static NSString *const kSettingsVCSectionTitleServerURL = @"Servidor";
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

@end

@implementation SettingsVC

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return kSettingsVCSectionTitleServerURL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSettingsVCCellIdentifier];
    
    if (!cell) {
        
        DDLogError(@"SettingsVC::cellForRowAtIndexPath - Cell is nil");
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue -> %@", sender);
    
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
