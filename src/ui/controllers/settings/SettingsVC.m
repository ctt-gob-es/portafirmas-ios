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
#import "GlobalConstants.h"
#import "UserRolesService.h"
#import "PushNotificationService.h"
#import "SelectRoleViewController.h"

#import "Port_firmas-Swift.h"

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


@interface SettingsVC () <OnboardingDelegate>
{
    NSString *_currentCertificate;
    NSArray *userDefaultsKeys;
}

@property (nonatomic, strong) IBOutlet UIButton *accessButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic) BOOL roleAlreadySelected;
@property BOOL showingAlert;

@end

@implementation SettingsVC


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyLaunchedBefore]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:kPFUserDefaultsKeyLaunchedBefore];

        DefaultNavigationViewController *nvc = [[DefaultNavigationViewController alloc] init];
        OnboardingSplashViewController *vc = [[OnboardingSplashViewController alloc] init];
        [nvc initWithRootViewController:vc];
        nvc.onboardingDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nvc animated:YES completion:nil];
    }

        self.titleBar.title = [NSString stringWithFormat: @"Configuration_Page_Title".localized,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateAccessButton];
	[self disableRemoteCertificatesIfCertificateSelected];
    if(_roleAlreadySelected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kSettingsVCSegueIdentifierAccess sender:self];
        });
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    _roleAlreadySelected = NO;
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

- (void) showLoginWebView {
	dispatch_async(dispatch_get_main_queue(), ^{
		WKWebViewConfiguration *wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
        self.webView = [[WKWebView alloc] initWithFrame: self.view.bounds configuration: wkWebViewConfiguration];
		self.webView.navigationDelegate = self;
		NSString *url=[[LoginService instance] urlForRemoteCertificates];
		NSURL *nsurl=[NSURL URLWithString:url];
		
        
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: nsurl];
        NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        
        for (NSHTTPCookie *cookie in cookies) {
            [[[[self.webView configuration] websiteDataStore] httpCookieStore] setCookie: cookie completionHandler:^{
                            [self.webView loadRequest:nsrequest];
                            [self.view addSubview: self.webView];
                        }];
        }
    });
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	__block BOOL segue = NO;
    self.showingAlert = NO;
	if ([identifier isEqualToString:kSettingsVCSegueIdentifierAccess]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyRemoteCertificatesSelection]) {
			[[LoginService instance] loginWithRemoteCertificates:^{
                [self showLoginWebView];
			} failure:^(NSError *error) {
				segue = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					[[ErrorService instance] showLoginErrorAlertView];
				});
			}];
		} else {
			[[LoginService instance] loginWithCertificate:^{
				segue = YES;
				dispatch_async(dispatch_get_main_queue(), ^{
                    [[UserRolesService instance] getUserRoles:^(NSDictionary *content) {
                        NSDictionary *responseError = [content objectForKey:kErrorRqsrcnfg];
                        if (responseError) {
                            // Old system that does not suppor roles maybe show something continue as always
                            [self setCompatibilityInLocalStorage:NO];
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserNotificationsActivated]
                                ) {
                                [[PushNotificationService instance] initializePushNotificationsService:false];
                            }
                            segue = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self performSegueWithIdentifier:identifier sender:self];
                            });
                            
                        } else {
                            [self setCompatibilityInLocalStorage:YES];
                            [self setPortafirmasNotificationsConfigInLocalStorage: [[content objectForKey:@"rsgtsrcg"] objectForKey:@"smcg"]];
                            [self setUserNotificationsConfigInLocalStorage: [[content objectForKey:@"rsgtsrcg"] objectForKey:@"ntpsh"]];
                            [self initializePushNotificationServiceIfActivated];
                            NSDictionary *responseUserRolesDict = [[content objectForKey:@"rsgtsrcg"] objectForKey:@"rls"];
                            [self setUserHasValidator:[[content objectForKey:@"rsgtsrcg"] objectForKey:@"srvrf"]];
                            if ([responseUserRolesDict count] == 0) {
                                //User with no roles continue as always
                                segue = YES;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self performSegueWithIdentifier:identifier sender:self];
                                });
                            } else {
                                //User with roles navigate to rol selection
                            [self setRolesInLocalStorage: responseUserRolesDict];
                                SelectRoleViewController *selectRoleViewController = [[SelectRoleViewController alloc] initWithNibName: @"SelectRoleViewController" bundle: nil];
                                selectRoleViewController.delegate = self;
                                [selectRoleViewController setModalPresentationStyle:UIModalPresentationFullScreen];
                                [self.navigationController presentViewController:selectRoleViewController animated:YES completion:nil];
                            }
                        }
                    } failure:^(NSError *error) {
                        segue = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[ErrorService instance] showLoginErrorAlertView];
                        });
                    }];
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
                        if (!self.showingAlert) {
                            self.showingAlert = YES;
                            [[ErrorService instance] showLoginErrorAlertView];
                        }
					});
				}
			}];
		}
	} else {
        segue = YES;
    }
    return segue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:kSettingsVCSegueIdentifierAccess]) {
        
        if (![userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate] && ![[LoginService instance] remoteCertificateLoginOK]) {

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

#pragma mark - User Configuration Methods

- (void) userConfigurationRequest {
    [[UserRolesService instance] getUserRoles:^(NSDictionary *content) {
        NSDictionary *responseError = [content objectForKey:kErrorRqsrcnfg];
        if (responseError) {
            // Old system that does not suppor roles maybe show something continue as always
            [self setCompatibilityInLocalStorage:NO];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserNotificationsActivated]
                ) {
                [[PushNotificationService instance] initializePushNotificationsService:false];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:kSettingsVCSegueIdentifierAccess sender:self];
            });
        } else {
            [self setCompatibilityInLocalStorage:YES];
            [self setPortafirmasNotificationsConfigInLocalStorage: [[content objectForKey:@"rsgtsrcg"] objectForKey:@"smcg"]];
            [self setUserNotificationsConfigInLocalStorage: [[content objectForKey:@"rsgtsrcg"] objectForKey:@"ntpsh"]];
            [self initializePushNotificationServiceIfActivated];
            NSDictionary *responseUserRolesDict = [[content objectForKey:@"rsgtsrcg"] objectForKey:@"rls"];
            [self setUserHasValidator:[[content objectForKey:@"rsgtsrcg"] objectForKey:@"srvrf"]];
            if ([responseUserRolesDict count] == 0) {
                //User with no roles continue as always
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:kSettingsVCSegueIdentifierAccess sender:self];
                });
            } else {
                //User with roles navigate to rol selection
                [self setRolesInLocalStorage: responseUserRolesDict];
                SelectRoleViewController *selectRoleViewController = [[SelectRoleViewController alloc] initWithNibName: @"SelectRoleViewController" bundle: nil];
                selectRoleViewController.delegate = self;
                [selectRoleViewController setModalPresentationStyle:UIModalPresentationFullScreen];
                [self.navigationController presentViewController:selectRoleViewController animated:YES completion:nil];
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ErrorService instance] showLoginErrorAlertView];
        });
    }];
}

- (void) initializePushNotificationServiceIfActivated {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyPortafirmasNotificationsActivated] && [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyUserNotificationsActivated]) {
        [[PushNotificationService instance] initializePushNotificationsService:false];
    }
}

- (void) setUserHasValidator:(NSDictionary*)userHasValidator {
    [[NSUserDefaults standardUserDefaults] setBool:[[userHasValidator objectForKey:kContentKey]  isEqual: kUserRoleUserHasValidator] forKey:kPFUserDefaultsKeyUserHasValidator];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setRolesInLocalStorage:(NSDictionary*)userRolesDictionary {
    NSArray * userRolesArray = [userRolesDictionary allValues];
    [[NSUserDefaults standardUserDefaults] setObject:userRolesArray forKey:kPFUserDefaultsKeyUserRoles];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCompatibilityInLocalStorage:(BOOL)isCompatible {
    [[NSUserDefaults standardUserDefaults] setBool:isCompatible forKey:kPFUserDefaultsKeyUserConfigurationCompatible];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setPortafirmasNotificationsConfigInLocalStorage:(NSDictionary *)notificationsDictionary {
    if (notificationsDictionary != nil ) {
        [[NSUserDefaults standardUserDefaults] setBool:[[notificationsDictionary objectForKey:kContentKey]  isEqual: kPortafirmasNotificationsConfigActivated] forKey:kPFUserDefaultsKeyPortafirmasNotificationsActivated];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) setUserNotificationsConfigInLocalStorage:(NSDictionary *)notificationsDictionary {
    if (notificationsDictionary != nil ) {
        if ([[notificationsDictionary objectForKey:kContentKey]  isEqualToString: kUserNotificationsConfigActivated]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPFUserDefaultsKeyUserNotificationsActivated];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPFUserDefaultsKeyUserNotificationsActivated];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieStorage cookies]) {
        NSLog(@"%@", cookie);
    }
    
    NSURLRequest *request = navigationAction.request;
    NSString *requestString = [[request URL]absoluteString];
	NSArray *urlFragments= [requestString componentsSeparatedByString: kStringSlash];
	if ([[urlFragments lastObject] rangeOfString:kError].location != NSNotFound) {
		[[ErrorService instance] showLoginErrorAlertView];
		[self.webView removeFromSuperview];
		return decisionHandler(WKNavigationActionPolicyCancel);
	}
	if ([[urlFragments lastObject] rangeOfString:kOk].location != NSNotFound) {
		[self.webView removeFromSuperview];
        [self userConfigurationRequest];
		return decisionHandler(WKNavigationActionPolicyCancel);
	}
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - RoleSelectedDelegate

- (void) rolesSelected {
    _roleAlreadySelected = YES;
}

- (void)viewDismissed {
    [self.tableView reloadData];
    [self updateAccessButton];
}
@end
