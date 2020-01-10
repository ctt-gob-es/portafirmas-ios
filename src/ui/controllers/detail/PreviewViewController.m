//
//  PreviewViewController.m
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import "PreviewViewController.h"
#import "PreviewXMLController.h"
#import "WSDataController.h"
#import "AppDelegate.h"
#import "Base64Utils.h"
#import "XMLController.h"
#import "AttachedDoc.h"
#import "Document.h"

@interface PreviewViewController ()
{
    BOOL _isShowingAlertView;
}

@end

@implementation PreviewViewController
@synthesize webView = _webView;
@synthesize  docId = _docId, documentDataSource = _documentDataSource, attachedDataSource = _attachedDataSource;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        // Custom initialization

        dataController = [[WSDataController alloc] init];
        dataController.delegate = self;
        _isShowingAlertView = NO;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWebService];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.parentViewController setHidesBottomBarWhenPushed:TRUE];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)loadWebService
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    NSString *data = [PreviewXMLController buildRequestWithId:_docId];

    // loadRequest
    [dataController loadPostRequestWithData:data code:_requestCode];
    [dataController startConnection];
}

- (void)didReceiveParserWithError:(NSString *)errorString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Error".localized
                                                                             message:errorString
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Ok".localized style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)doParse:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (dataString) {
        NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
        XMLController *parser = [[XMLController alloc] init];
        [nsXmlParser setDelegate:parser];

        if ([nsXmlParser parse] && [parser finishWithError]) {
            [self showAlertWithDelegateAndMessage:[NSString stringWithFormat:@"%@\n(%@)", parser.err, parser.errorCode]];

            return;
        }
    }
    
    NSString *mmtp;
    
    if (_documentDataSource != nil) {
        mmtp = _documentDataSource.mmtp;
    } else {
        mmtp = _attachedDataSource.mmtp;
    }

    [_webView loadData:data
              MIMEType:mmtp
              textEncodingName:@"UTF-8"
              baseURL: [NSURL URLWithString:@"http://"]
     ];
    [_webView setScalesPageToFit:YES];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIInterfaceOrientation des = self.interfaceOrientation;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad
        if (des == UIInterfaceOrientationPortrait || des == UIInterfaceOrientationPortraitUpsideDown) { // ipad-portairait

        } else { // ipad -landscape

        }
    } else { // iphone
        UIInterfaceOrientation des = self.interfaceOrientation;

        if (des == UIInterfaceOrientationPortrait || des == UIInterfaceOrientationPortraitUpsideDown) { // iphone portrait

        } else { // iphone -landscape

        }
    }

    return YES;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showAlertWithDelegateAndMessage:@"Lo sentimos pero la previsualización de este tipo de documentos no está disponible."];
}

- (void)showAlertWithDelegateAndMessage:(NSString *)message
{
    if (!_isShowingAlertView) {
        _isShowingAlertView = YES;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Alert_View_Preview_Not_Available".localized
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Ok".localized style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
