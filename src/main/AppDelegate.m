//
//  AppDelegate.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 29/10/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+Conversion.h"

@implementation AppDelegate
// @synthesize certificate, appConfig=_appConfig;
@synthesize  appConfig = _appConfig;

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
    DDLogError(@"CRASH: %@", exception);
    DDLogError(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupLogger];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [self customizeAppearance];
    [self loadSelectedCertificate];
    
    [[PushNotificationService instance] initializePushNotificationsService];
    
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

- (void)setupLogger
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
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

#pragma mark - Notifications Support

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSString *tokenHex = [deviceToken hexadecimalString];
    DDLogDebug(@"Device Registered for notifications, token: %@", [tokenHex uppercaseString]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    DDLogError(@"Error Register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogDebug(@"Receive remote notification: %@", userInfo);
}

@end
