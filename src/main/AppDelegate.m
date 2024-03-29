//
//  AppDelegate.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 29/10/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+Conversion.h"
#import "UnassignedRequestTableViewController.h"
#import "LoginService.h"
#import "DefaultServersData.h"
#import "NotificationHandler.h"

#import "Port_firmas-Swift.h"

@implementation AppDelegate
// @synthesize certificate, appConfig=_appConfig;
@synthesize  appConfig = _appConfig;
@synthesize mainTab = _mainTab;

- (id)init
{
    self = [super init];

    // Find out the path of Application config plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];

    // Load the file content and read the data into arrays
    _appConfig = [[NSDictionary alloc] initWithContentsOfFile:path];

    return self;
}

void uncaughtExceptionHandler(NSException *exception)
{
	NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [DefaultServersData createDefaultServersIsNotExist];

    [self handleNavigation];

    [self customizeAppearance];
    [self loadSelectedCertificate];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)customizeAppearance
{
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:108.f / 255.f green:25.4 / 255.f blue:31.f / 255.f alpha:1]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] } forState:UIControlStateNormal];

    [self.window setBackgroundColor:[UIColor whiteColor]];
}

- (void)loadSelectedCertificate
{
    NSArray *userDefaultsKeys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys;
    
    if ([userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate]) {
        NSDictionary *currentCertificateInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPFUserDefaultsKeyCurrentCertificate];
        NSString *currentCertificateName = currentCertificateInfo[kPFUserDefaultsKeyAlias];
        if (currentCertificateName && [[CertificateUtils sharedWrapper] searchIdentityByName:currentCertificateName] == YES) {
            [[CertificateUtils sharedWrapper] setSelectedCertificateName:currentCertificateName];
        }
    }
}
    
- (void)showAlertView: (NSString *) message {
    
    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Token Registered" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // continue your work
        
        // important to hide the window after work completed.
        // this also keeps a reference to the window until the action is invoked.
        topWindow.hidden = YES;
    }]];
    
    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Notifications Support

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSString *tokenHex = [deviceToken hexadecimalString];     
   // [self showAlertView:[tokenHex uppercaseString]];
    
    /*if (!IOS_NEWER_OR_EQUAL_TO_10 && [[PushNotificationService instance] hasUserAllowNotifications] == false) {
        [[PushNotificationService instance] resetNotificationRequired];
    }*/
    
    [[PushNotificationService instance] updateTokenOfPushNotificationsService: [tokenHex uppercaseString]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishSubscriptionProcessNotification" object:self];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo != nil) {
        if ([NotificationHandler isNotificationForUserLogged:userInfo]){
            [self openPendingTabAndLoadData];
        }
    }
}

- (void) openPendingTabAndLoadData {
    if (self.mainTab && [[LoginService instance] serverSupportLogin]) {
        [self.mainTab setSelectedIndex:0];
        UINavigationController *nav = [self.mainTab.viewControllers objectAtIndex:0];
        UnassignedRequestTableViewController *pendingViewController = (UnassignedRequestTableViewController *)nav.rootViewController;
        [pendingViewController loadData];
    }
}

+ (UIViewController*) presentingViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void) handleNavigation {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyLaunchedBefore]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kPFUserDefaultsKeyLaunchedBefore];

            DefaultNavigationViewController *nvc = [[DefaultNavigationViewController alloc] init];
            OnboardingSplashViewController *vc = [[OnboardingSplashViewController alloc] initWithNibName:@"OnboardingSplashView" bundle:nil];
            [nvc initWithRootViewController:vc];
            self.window.rootViewController = nvc;
            [self.window makeKeyAndVisible];
        } else {
            UIViewController *mainVC = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
            [mainVC setModalPresentationStyle:UIModalPresentationFullScreen];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
    } else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIViewController *mainVC = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateInitialViewController];
        [mainVC setModalPresentationStyle:UIModalPresentationFullScreen];
        self.window.rootViewController = mainVC;
        [self.window makeKeyAndVisible];
    }
}

@end
