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

- (void) showNotAllowNotifications {
    NSString * title = @"Las notificaciones estan deshabilitadas";
    NSString * msg = @"Has de ir a ajustes en tu dispositivo y luego a Notificaciones buscar PortaFirmas y permitir notificaciones";
    [self showAlertViewWithTitle:title andMessage:msg];
}

- (void) showAlertViewWithMessage: (NSString *) message {
    [self showAlertViewWithTitle:@"" andMessage:message]
    ;
}

- (void) showAlertViewWithTitle: (NSString *) title andMessage: (NSString*) message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [[AppDelegate presentingViewController] presentViewController:alert animated:YES completion:nil];
}

@end
