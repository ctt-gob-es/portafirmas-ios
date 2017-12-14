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
    NSString * msg = @"No ha sido posible completar el proceso de identificación";
    [self showAlertViewWithMessage:msg];
}

- (void) showAlertViewWithMessage: (NSString *) message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [[AppDelegate presentingViewController] presentViewController:alert animated:YES completion:nil];
}

@end
