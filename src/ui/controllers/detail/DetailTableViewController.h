//
//  DetailTableViewController.h
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Detail.h"
#import "WSDataController.h"
#import "RequestSignerController.h"
#import "PFRequest.h"

@interface DetailTableViewController : UITableViewController<WSDelegate, UIActionSheetDelegate, RequestSignerEvent, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{

    Detail *_dataSource;
    NSArray *_selectedRows;
    NSString *_requestId;
    WSDataController *wsController;
    NSDictionary *appConfig;
    BOOL _signEnabled;
}

@property (weak, nonatomic) IBOutlet UILabel *referenceLbl;
@property (strong, nonatomic) IBOutlet UILabel *signLinesTypeLbl;
@property (strong, nonatomic) IBOutlet UILabel *requestTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *inputDateLbl;
@property (strong, nonatomic) IBOutlet UITextView *applicationTitleTextView;
@property (strong, nonatomic) IBOutlet UITextView *applicationTextView;
@property (strong, nonatomic) IBOutlet UILabel *rejectLbl;
@property (strong, nonatomic) IBOutlet UITextView *sendersTitleTextView;
@property (strong, nonatomic) IBOutlet UITextView *sendersTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendersMoreButton;
@property (strong, nonatomic) IBOutlet UITextView *subjectTitleTextView;
@property (strong, nonatomic) IBOutlet UITextView *subjectTextView;
@property (strong, nonatomic) IBOutlet UILabel *inputExpirationDateLbl;
@property (strong, nonatomic) NSString *requestId;
@property (strong, nonatomic) Detail *dataSource;
@property (strong, nonatomic) PFRequest *dataSourceRequest;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDocumentAction;
@property (strong, nonatomic) IBOutlet UITableViewCell *expirationTableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cellBehindExpirationDate;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cellBehindRejectExplanation;
@property (strong, nonatomic) IBOutlet UITableViewCell *rejectExplanationTableViewCell;
@property (readwrite, nonatomic) BOOL signEnabled;
@end
