//
//  DetailTableViewController.m
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import "DetailTableViewController.h"
#import "BaseListTVC.h"
#import "DetailXMLController.h"
#import "Detail.h"
#import "AttachmentViewController.h"
#import "ReceiversViewController.h"
#import "WSDataController.h"
#include "AppDelegate.h"
#import "PFRequest.h"
#import "RejectXMLController.h"
#import "ApproveXMLController.h"
#import "DetailCell.h"

static NSString *const kDetailCell = @"detailCell";
static NSString *const kDetailCellNibName = @"DetailCell";
static NSString *const kEmptyString = @"";
static NSString *const kEndOfLine = @"\r";
static NSString *const kMainStoryboardIPhoneIdentifier = @"MainStoryboard_iPhone";
static NSString *const kAttachmentsListViewIdentifier = @"AttachmentsListView";
static NSString *const kReceiversListViewIdentifier = @"ReceiversListView";
static NSString *const kRequestDetailURLKeyName = @"requestDetailURL";
static NSString *const kKOStatusString = @"KO";
static NSString *const kAppendFormatString = @" %@";

typedef NS_ENUM (NSInteger, PFDocumentAction)
{
    PFDocumentActionReject,
    PFDocumentActionSign,
    PFDocumentActionCancel
};

typedef enum cellTypes
{
    From,
    Subject,
    Reference,
    RejectExplanation,
    AttachedDocument,
    Receivers,
    RequestType,
    SignType,
    Date,
    ExpirationDate,
    Application,
	Message
} CellTypes;

NSInteger const numberOfRows = 12;
CGFloat const defaultCellHeight = 44;
CGFloat const noCellHeight = 0;
CGFloat const rejectCellTitleCellWidth = 150;
CGFloat const largeTitleCellWidth = 200;

@interface DetailTableViewController ()
{
    UIAlertController *_documentActionSheet;
    RequestSignerController *_requestSignerController;
    PFWaitingResponseType _waitingResponseType;
    NSString *motivoRechazo;
    BOOL isSuccessReject;
}

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation DetailTableViewController

@synthesize requestId = _requestId, dataSource = _dataSource, signEnabled = _signEnabled;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
        wsController = [[WSDataController alloc] init];
        wsController.delegate = self;
        _signEnabled = FALSE;
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [wsController cancelConnection];
    [self setBtnDocumentAction:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    // Enable or disable  action button
    [_btnDocumentAction setEnabled:_signEnabled];
    [self loadWebService];
    self.tableView.estimatedRowHeight = defaultCellHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCell];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:kDetailCellNibName bundle:nil] forCellReuseIdentifier:kDetailCell];
        cell = [tableView dequeueReusableCellWithIdentifier:kDetailCell];
    }
    NSString *title = kEmptyString;
    NSString *value = kEmptyString;
    switch (indexPath.row) {
        case From:
            title = NSLocalizedString(@"Cell_Title_From", nil);
            value = [self getSenders];
            [cell setDarkStyle];
            break;
        case Subject:
            title = NSLocalizedString(@"Cell_Title_Subject", nil);
            value = [self getSubject];
            [cell setDarkStyle];
            [cell setValueBoldStyle];
            break;
        case Reference:
            self.referenceLbl.text = _dataSource.ref;
            title = NSLocalizedString(@"Cell_Title_Reference", nil);
            value = [self getReference];
            [cell setDarkStyle];
            break;
        case RejectExplanation:
            title = NSLocalizedString(@"Cell_Title_RejectExplanation", nil);
            value = [self getRejectExplanation];
            [cell setDarkStyle];
            [cell increaseTitleLabelWidth: rejectCellTitleCellWidth];
            [cell hideLabelsIfNeeded: ![self rejectExplanationExists]];
            break;
        case AttachedDocument:
            title = NSLocalizedString(@"Cell_Title_AttachedDocument", nil);
            [cell setValueInNewViewStyle];
            [cell increaseTitleLabelWidth:largeTitleCellWidth];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case Receivers:
            title = NSLocalizedString(@"Cell_Title_Receivers", nil);
            [cell setValueInNewViewStyle];
            [cell increaseTitleLabelWidth: largeTitleCellWidth];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case RequestType:
            title = NSLocalizedString(@"Cell_Title_RequestType", nil);
            value = [self getRequestType];
            [cell setClearStyle];
            [cell setValueBoldStyle];
            break;
        case SignType:
            title = NSLocalizedString(@"Cell_Title_SignType", nil);
            value = [self getSignType];
            [cell setClearStyle];
            break;
        case Date:
            title = NSLocalizedString(@"Cell_Title_Date", nil);
            value = [self getDate];
            [cell setClearStyle];
            break;
        case ExpirationDate:
            title = NSLocalizedString(@"Cell_Title_ExpirationDate", nil);
            value = [self getExpirationDate];
            [cell setClearStyle];
            [cell hideLabelsIfNeeded: !_dataSource.expdate];
            break;
        case Application:
            title = NSLocalizedString(@"Cell_Title_Application", nil);
            value = [self getApplication];
            [cell setClearStyle];
            break;
		case Message:
			title = NSLocalizedString(@"Cell_Title_Message", nil);
			value = [self getMessage];
			[cell setClearStyle];
            [cell hideLabelsIfNeeded: ![self messageExists]];
			break;
    }
    [cell setCellTitle: title];
    [cell setCellValue: value];
    return cell;
}

-(NSString *)getSenders
{
    NSMutableArray* senders = _dataSource.senders;
    return [senders componentsJoinedByString: kEndOfLine];
}

-(NSString *)getSubject
{
    NSString *subject = _dataSource.subj;
    return subject;
}

-(NSString *)getReference
{
    NSString *reference = _dataSource.ref;
    return reference;
}

-(NSString *)getRejectExplanation
{
    NSString *reference = _dataSource.rejt;
    return reference;
}

-(NSString *)getRequestType
{
    NSString *requestType = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? NSLocalizedString(@"Request_Type_Firma", nil) : NSLocalizedString(@"Request_Type_Visto_Bueno", nil);
    return requestType;
}

-(NSString *)getSignType
{
    NSString *signType = _dataSource.signlinestype;
    return signType;
}

-(NSString *)getDate
{
    NSString *date = _dataSource.date;
    return date;
}

-(NSString *)getExpirationDate
{
    NSString *expirationDate = _dataSource.expdate;
    return expirationDate;
}

-(NSString *)getApplication
{
    NSString *application = _dataSource.app;
    return application;
}

-(NSString *)getMessage
{
	NSString *message = _dataSource.msg;
	return message;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardIPhoneIdentifier bundle:nil];

    switch (indexPath.row) {
        case AttachedDocument: {
            AttachmentViewController *attachmentController =  (AttachmentViewController *)[storyboard instantiateViewControllerWithIdentifier:kAttachmentsListViewIdentifier];
            attachmentController.documentsDataSource = _dataSource.documents;
            attachmentController.attachedDocsDataSource = _dataSource.attachedDocs;
            [attachmentController setDetail:_dataSource];
            [attachmentController setRequestStatus:[PFHelper getPFRequestStatusFromString:_dataSourceRequest.view]];
            [self.navigationController pushViewController:attachmentController animated:YES];
            break;
        }
        case Receivers: {
            ReceiversViewController *receiversController =  (ReceiversViewController *)[storyboard instantiateViewControllerWithIdentifier:kReceiversListViewIdentifier];
            receiversController.dataSource = _dataSource.signlines;
            [self.navigationController pushViewController:receiversController animated:YES];
            break;
        }
    }
}

- (void)loadWebService
{
    NSString *data = [DetailXMLController buildRequestWithId:_requestId];
    // Load Detail request
    _waitingResponseType = PFWaitingResponseTypeDetail;
    [wsController loadPostRequestWithData:data code:4];
    [wsController startConnection];
}

#pragma mark - UIActionSheet methods

- (IBAction)didTapDocumentActionButton:(id)sender
{
    NSString *signButtonTitle = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? NSLocalizedString(@"Sign", nil) : NSLocalizedString(@"Approval", nil);
    UIAlertController *alertController = [self obtainAlertController];
    UIAlertAction* reject = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reject", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [self rejectAction];
                             }];
    UIAlertAction* sign = [UIAlertAction actionWithTitle:signButtonTitle
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)
                           {
                               [self signAction];
                           }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:reject];
    [alertController addAction:sign];
    [alertController addAction:cancel];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = self.view;
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIAlertController *)obtainAlertController {
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //iPad
        return [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    } else {
        //    iPhone
        return [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    }
}

- (void)rejectAction
{
    // Preguntamos el por qué del rechazo
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rejection_of_requests", nil) message:NSLocalizedString(@"Indicate_Reason_For_Rejection", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *conti = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self rejectActionClickContinueButton:alert];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Reason_For_Rejection", nil);
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    [alert addAction:cancel];
    [alert addAction:conti];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)signAction
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    if ([(Detail *)_dataSource type] == PFRequestTypeSign) {
        [self startSignRequest];
    } else {
        [self startApprovalRequest];
    }
}

- (void) rejectActionClickContinueButton: (UIAlertController *)alertController {
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    if ([alertController.textFields count] != 0) {
        NSArray *textfields = alertController.textFields;
        UITextField *nameTextfield = textfields[0];
        motivoRechazo = nameTextfield.text;
    }
    NSString *data = [RejectXMLController buildRequestWithIds:_selectedRows motivoR: motivoRechazo];
    _waitingResponseType = PFWaitingResponseTypeRejection;
    [wsController loadPostRequestWithData:data code:PFRequestCodeReject];
    [wsController startConnection];
}

#pragma mark - Network Methods

- (void)startSignRequest
{
    _waitingResponseType = PFWaitingResponseTypeSign;
    _requestSignerController = [[RequestSignerController alloc] init];
    _requestSignerController.delegate = self;
    [_requestSignerController loadPreSignDetailWithCurrentCertificate:_dataSource];
}

- (void)startApprovalRequest
{
    _waitingResponseType = PFWaitingResponseTypeApproval;
    NSString *requestData = [ApproveXMLController buildRequestWithRequestArray:@[_dataSource]];

    [wsController loadPostRequestWithData:requestData code:PFRequestCodeApprove];
    [wsController startConnection];
}

- (void)loadDetailInfo
{
    self.referenceLbl.text = _dataSource.ref;
    self.inputDateLbl.text = _dataSource.date;
    self.sendersMoreButton.hidden = YES;
    self.signLinesTypeLbl.text = _dataSource.signlinestype;
    NSString *requestTypeText = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? NSLocalizedString(@"Request_Type_Firma", nil) : NSLocalizedString(@"Request_Type_Visto_Bueno", nil);
    self.requestTypeLbl.text = requestTypeText;
    [self showSenders];
    _selectedRows = nil;
    PFRequest *detailRequest = [[PFRequest alloc] initWithId:_requestId];
    detailRequest.documents = _dataSource.documents;
    _selectedRows = [[NSArray alloc] initWithObjects:detailRequest, nil];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case RejectExplanation:
            return (![self rejectExplanationExists]) ? noCellHeight : defaultCellHeight;
            break;
        case ExpirationDate:
            return (!_dataSource.expdate)? noCellHeight : defaultCellHeight;
            break;
            return defaultCellHeight;
        case AttachedDocument:
            return defaultCellHeight;
            break;
        case Receivers:
            return defaultCellHeight;
            break;
		case Message:
			return (!_dataSource.msg)? noCellHeight : tableView.rowHeight;
			break;
    }
    return tableView.rowHeight;
}

- (BOOL)rejectExplanationExists
{
    // Avoid the strings only with whitespaces. By default from the server the reject object is @" " (length == 1)
    NSString* trimmedTextString = [_dataSource.rejt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (_dataSource.rejt && [trimmedTextString length] != 0);
}

- (BOOL)messageExists
{
    // Avoid the strings only with whitespaces. By default from the server the reject object is @" " (length == 1)
	NSString* trimmedTextString = [_dataSource.msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (_dataSource.msg && [trimmedTextString length] != 0);
}

- (void)showSenders
{
    //Aling to the top the textviews for this Table View Cell
    [self.sendersTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.sendersTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTextView.textContainer.lineFragmentPadding = 0;
    
    NSMutableArray* senders = _dataSource.senders;
    NSString *joinedSenders = [senders componentsJoinedByString:kEndOfLine];
    self.sendersTextView.text = joinedSenders;
    // Scroll to the top
    [self.sendersTextView scrollRangeToVisible:NSMakeRange(0,0)];
    if ([senders count] > 2 ){
        self.sendersMoreButton.hidden = NO;
        NSString *textButton1 = NSLocalizedString(@"Detail_senders_first_button", nil);
        NSString *textButton2 = NSLocalizedString(@"Detail_senders_second_button", nil);
        NSInteger restOfSenders = [senders count] - 2;
        NSString *textButton = [NSString stringWithFormat:@"%@%ld%@",textButton1, (long)restOfSenders, textButton2];
        [self.sendersMoreButton setTitle:textButton forState:UIControlStateNormal];
    } else{
        self.sendersMoreButton.hidden = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIInterfaceOrientation des = self.interfaceOrientation;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad
        if (des == UIInterfaceOrientationPortrait || des == UIInterfaceOrientationPortraitUpsideDown) { // ipad-portairait
        } else {                                                // ipad -landscape
        }
    } else {                                                    // iphone
        UIInterfaceOrientation des = self.interfaceOrientation;

        if (des == UIInterfaceOrientationPortrait || des == UIInterfaceOrientationPortraitUpsideDown) { // iphone portrait
        } else {                                                // iphone -landscape
        }
    }

    return YES;
}

#pragma mark - WSDataController delegate

- (void)doParse:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    id <NSXMLParserDelegate> parser = [self parserForCurrentRequest];
    [nsXmlParser setDelegate:parser];

    if ([nsXmlParser parse]) {
        
        if (_waitingResponseType == PFWaitingResponseTypeRejection) {
            [self didReceiveRejectResult:[(RejectXMLController *)parser dataSource]];
        }
        else if (_waitingResponseType == PFWaitingResponseTypeApproval) {
            [self didReceiveApprovalResult:[(ApproveXMLController *)parser dataSource]];
        }
        else {
            [self didFinisParsingWithParser:parser];
        }
    }
    else {
        [self didReceiveParserWithError:NSLocalizedString(@"Detail_view_error_server_connection", nil)];
    }
}

- (id <NSXMLParserDelegate> )parserForCurrentRequest
{
    if (_waitingResponseType == PFWaitingResponseTypeDetail) {
        return [[DetailXMLController alloc] initXMLParser];
    } else if (_waitingResponseType == PFWaitingResponseTypeRejection) {
        return [[RejectXMLController alloc] initXMLParser];
    } else if (_waitingResponseType == PFWaitingResponseTypeApproval) {
        return [[ApproveXMLController alloc] init];
    }

    return nil;
}

- (void)didReceiveRejectResult:(NSArray *)requestsSigned
{
    isSuccessReject = YES;
    BOOL processedOK = TRUE;

    for (PFRequestResult *request in requestsSigned) {
        if ([[request status] isEqualToString:kKOStatusString]) {
            [self didReceiveError:[[NSString alloc] initWithFormat:NSLocalizedString(@"Detail_view_error_processing_request", nil), [request rejectid]]];
            processedOK = FALSE;
        }
    }

    if (processedOK) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                                                                 message:NSLocalizedString(@"Correctly_rejected_requests", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self dismissSelfView];
                                                         }];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }
	
   dispatch_async(dispatch_get_main_queue(), ^{
	   [self dismissViewControllerAnimated:YES completion:nil];
	});

}

- (void)didReceivedRejectionResponse:(NSData *)responseData
{
    
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:responseData];
    RejectXMLController *parser = [[RejectXMLController alloc] initXMLParser];
    
    [nsXmlParser setDelegate:parser];
    BOOL success = [nsXmlParser parse];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    if (success) {
        NSArray *rejectsReq = [parser dataSource];
        [self didReceiveRejectResult:rejectsReq];
    }
    else {
        [self didReceiveError:NSLocalizedString(@"Detail_view_error_server_connection_501", nil)];
    }
}

- (void)didReceiveApprovalResult:(NSArray *)approvedRequests
{
    NSMutableArray *idsForRequestsWithError = [@[] mutableCopy];

    [approvedRequests enumerateObjectsUsingBlock:^(PFRequest *request, NSUInteger idx, BOOL *stop) {
         if ([request.status isEqualToString:kKOStatusString]) {
             [idsForRequestsWithError addObject:request.reqid];
         }
     }];

    if (idsForRequestsWithError.count == 0) {
        // @" Peticiones firmadas corrrectamente"
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Alert_View_Request_Processed_Correctly", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
        [self dismissSelfView];
    } else {
        NSString *errorMessage;
        if (idsForRequestsWithError.count == 1) {
            errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Detail_view_error_processing_request", nil), idsForRequestsWithError[0]];
        } else {
            NSMutableString *errorIDSString = [kEmptyString mutableCopy];
            [idsForRequestsWithError enumerateObjectsUsingBlock:^(NSString *requestID, NSUInteger idx, BOOL *stop) {
                 [errorIDSString appendFormat:kAppendFormatString, requestID];
             }];
            errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Detail_view_error_processing_multiple_request", nil), errorIDSString];
        }
        [self didReceiveError:errorMessage];
        [self dismissSelfView];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
	   [self dismissViewControllerAnimated:YES completion:nil];
	});

}

- (void)didFinisParsingWithParser:(DetailXMLController *)parser
{
    BOOL finishOK = ![parser finishWithError];
    if (!finishOK) {
        NSString *errorCode = [parser errorCode] == nil ? kEmptyString : [parser errorCode];
        NSString *err = [parser err] == nil ? kEmptyString : [parser err];
        [self didReceiveError: [NSString stringWithFormat: NSLocalizedString(@"Detail_view_error_messages_from_server", nil), err, errorCode]];
        [_requestSignerController didReceiveParserWithError: [NSString stringWithFormat: NSLocalizedString(@"Detail_view_error_messages_from_server", nil), err, errorCode]];
    } else {
        _dataSource = [parser dataSource];
        [self loadDetailInfo];
        [self.tableView reloadData];
    }
}

- (void)didReceiveError:(NSString *)errorString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert_View_Error", nil) message:errorString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - RequestSignerEvent

- (void)didReceiveSignerRequestResult:(NSArray *)requestsSigned
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

    BOOL processedOK = YES;
    NSString *msg = kEmptyString;

    for (PFRequest *request in requestsSigned) {
        if ([[request status] isEqualToString: kKOStatusString]) {
            if (![msg isEqualToString:kEmptyString]) {
                msg = NSLocalizedString(@"Detail_view_error_signing_selected_requests", nil);
                break;
            } else {
                msg = NSLocalizedString(@"Detail_view_error_signing_selected_request", nil);
            }
            processedOK = FALSE;
        }
    }
    if (processedOK) {
        // @" Peticiones firmadas corrrectamente"
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                                                                 message:NSLocalizedString(@"Alert_View_Everything_Signed_Correctly", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissSelfView];
        }];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self didReceiveError:msg];
        [self dismissSelfView];
    }
}

- (void)dismissSelfView {
   dispatch_async(dispatch_get_main_queue(), ^{
	   [self dismissViewControllerAnimated:YES completion:nil];
	});
	
    [(BaseListTVC *)self.navigationController.previousViewController refreshInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showFIRMeWebView:(NSURL *) url {
	 dispatch_async(dispatch_get_main_queue(), ^{
		 [SVProgressHUD dismiss];
		 [self.navigationController setNavigationBarHidden:YES animated:YES];
		 self.webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		 [self->_webView setDelegate:self];
		 NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
		 [self.webView loadRequest: nsrequest];
		 [self.view addSubview: self.webView];
	 });
}

#pragma mark - WebViewDelegate

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSString *requestString = [[request URL] absoluteString];
	NSArray *urlFragments= [requestString componentsSeparatedByString: kStringSlash];
	if ([[urlFragments lastObject] rangeOfString:kError].location != NSNotFound) {
		[self.webView removeFromSuperview];
			}];
		 });
		return NO;
	}
	if ([[urlFragments lastObject] rangeOfString:kOk].location != NSNotFound) {
		[self.webView removeFromSuperview];
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismissWithCompletion:^{
			}];
		 });
		return NO;
	}
	return YES;
}

@end
