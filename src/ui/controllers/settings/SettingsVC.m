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
#import <WebKit/WebKit.h>

static const NSInteger kSettingsVCNumberOfSections = 3;
static const NSInteger kSettingsVCNumberOfRowsPerSection = 1;
static NSString *const kSettingsVCSectionTitleServerURL = @"Servidor";
static NSString *const kSettingsVCSectionTitleCertificate = @"Certificado";
static NSString *const kSettingsVCSectionTitleRemoteCertificates = @"Certificados remotos";
static NSString *const kSettingsVCCellIdentifier = @"SettingsCell";
static NSString *const kSettingsVCSegueIdentifierServerURLs = @"showServerListVC";
static NSString *const kSettingsVCSegueIdentifierCertificates = @"showRegisteredCertificates";
static NSString *const kSettingsVCSegueIdentifierAccess = @"showRequests";

typedef NS_ENUM (NSInteger, SettingsVCSection)
{
    SettingsVCSectionServerURL,
    SettingsVCSectionCertificate,
	SettingsVCSectionRemoteCertificates
};


@interface SettingsVC ()
{
    NSString *_currentCertificate;
    NSArray *userDefaultsKeys;
}

@property (nonatomic, strong) IBOutlet UIButton *accessButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (strong, nonatomic) UIWebView *webView;

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
	[self disableRemoteCertificatesIfCertificateSelected];
}

#pragma mark - User Interface

- (void)updateAccessButton
{
    userDefaultsKeys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys;
	[_accessButton setEnabled: [userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentServer] &&
	 ([userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate] ||
	  [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyRemoteCertificatesSelection])];
}

- (void)disableRemoteCertificatesIfCertificateSelected
{
	userDefaultsKeys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys;
	if ([userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPFUserDefaultsKeyRemoteCertificatesSelection];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
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
		case SettingsVCSectionRemoteCertificates:
			return kSettingsVCSectionTitleRemoteCertificates;
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSettingsVCCellIdentifier];
	cell.delegate = self;
    
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

- (void) showLoginWebView:(void(^)())success failure:(void(^)(NSError *error))failure {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.webView = [[UIWebView alloc] initWithFrame: self.view.bounds];
		[_webView setDelegate:self];
		NSString *url=[[LoginService instance] urlForRemoteCertificates];
		NSURL *nsurl=[NSURL URLWithString:url];
		NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
		[self.webView loadRequest: nsrequest];
		[self.view addSubview: self.webView];
	});
}

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
    DDLogDebug(@"Segue -> %@", sender);
    
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

- (void)didSelectRemoveCertificates:(SettingsCell *)sender {
	[self.tableView reloadData];
	[self updateAccessButton];
}

#pragma mark - WebViewDelegate

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSLog(@"shouldStartLoadWithRequest:  %@", request);
	return YES;
}

@end
