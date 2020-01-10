//
//  ErrorService.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 14/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import "ErrorService.h"
#import "AppDelegate.h"

@implementation ErrorService

+ (ErrorService *)instance {
    static ErrorService *errorService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorService = [[self alloc] init];
    });
    return errorService;
}

- (void) showLoginErrorAlertView {
    NSString * msg = @"Alert_View_Login_Failure_Message".localized;
    [self showAlertViewWithMessage:msg];
}

- (void) showNotAllowNotifications {
    NSString * title = @"Alert_View_Disable_Notifications_Title".localized;
    NSString * msg = @"Alert_View_Disable_Notifications_Message".localized;
    [self showAlertViewWithTitle:title andMessage:msg];
}

- (void) showAlertViewWithMessage: (NSString *) message {
    [self showAlertViewWithTitle:@"" andMessage:message];
}

- (void) showAlertViewWithTitle: (NSString *) title andMessage: (NSString*) message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Alert_View_Ok_Option".localized style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [[AppDelegate presentingViewController] presentViewController:alert animated:YES completion:nil];
}

@end
