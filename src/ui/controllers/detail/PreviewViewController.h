//
//  PreviewViewController.h
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDataController.h"

@class Document;
@class AttachedDoc;
@class WSDataController;

@interface PreviewViewController : UIViewController<WSDelegate, UIWebViewDelegate, UIAlertViewDelegate>
{
    WSDataController *dataController;
}

@property (strong, nonatomic) NSString *docId;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) Document *documentDataSource;
@property (strong, nonatomic) AttachedDoc *attachedDataSource;
@property (assign, nonatomic) PFRequestCode requestCode;

@end
