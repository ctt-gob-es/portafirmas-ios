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

typedef NS_ENUM (NSInteger, PFDocumentAction)
{
    PFDocumentActionReject,
    PFDocumentActionSign,
    PFDocumentActionCancel
};

@interface DetailTableViewController ()
{
    UIAlertController *_documentActionSheet;
    RequestSignerController *_requestSignerController;
    PFWaitingResponseType _waitingResponseType;
    NSString *motivoRechazo;
    BOOL isSuccessReject;
}

@end

@implementation DetailTableViewController

@synthesize requestId = _requestId, dataSource = _dataSource, signEnabled = _signEnabled;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        [SVProgressHUD dismiss];
        wsController = [[WSDataController alloc] init];
        wsController.delegate = self;
        _signEnabled = FALSE;
    }

    return self;
}

- (void)loadWebService
{
    NSString *url = [appConfig objectForKey:@"requestDetailURL"];

    DDLogDebug(@"DetailTableViewController::loadWebService.url=%@", url);

    NSString *data = [DetailXMLController buildRequestWithId:_requestId];
    DDLogDebug(@"DetailTableViewController::loadWebService.message data=%@", data);

    // Load Detail request
    _waitingResponseType = PFWaitingResponseTypeDetail;
    [wsController loadPostRequestWithData:data code:4];
    [wsController startConnection];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogDebug(@"DetailTableViewController::viewWillAppear");

    self.navigationController.toolbarHidden = YES;
}

//  [dataController loadRequestsWithURL:[DetailXMLController buildRequestWithId:_requestId]];
- (void)viewWillDisappear:(BOOL)animated
{
    // self.navigationController.toolbarHidden=YES;
    [wsController cancelConnection];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DDLogDebug(@"DetailTableViewController::viewDidLoad");

    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    // Enable or disable  action button
    [_btnDocumentAction setEnabled:_signEnabled];
    [self loadWebService];
}

- (void)viewDidUnload
{
    [self setBtnDocumentAction:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheet methods

- (IBAction)didTapDocumentActionButton:(id)sender
{
    NSString *signButtonTitle = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? NSLocalizedString(@"Sign", nil) : NSLocalizedString(@"Approval", nil);
    _documentActionSheet =[UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
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
    [_documentActionSheet addAction:reject];
    [_documentActionSheet addAction:sign];
    [_documentActionSheet addAction:cancel];
    [self presentViewController:_documentActionSheet animated:YES completion:nil];
}

- (void)rejectAction
{
    DDLogDebug(@"Reject Action....");
    // Preguntamos el por qué del rechazo
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rejection_of_requests", nil) message:NSLocalizedString(@"Indicate_Reason_For_Rejection", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *conti = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        DDLogDebug(@"UnassignedRequestTableViewController::Reject request....Selected rows=%lu", (unsigned long)[_selectedRows count]);
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        NSString *data = [RejectXMLController buildRequestWithIds:_selectedRows motivoR: motivoRechazo];
        DDLogDebug(@"UnassignedRequestTableViewController::rejectRequest input Data=%@", data);
        _waitingResponseType = PFWaitingResponseTypeRejection;
        [wsController loadPostRequestWithData:data code:PFRequestCodeReject];
        [wsController startConnection];
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
    DDLogDebug(@"Sign Action....\nAccept request....Selected rows=%lu", (unsigned long)[_selectedRows count]);

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];

    if ([(Detail *)_dataSource type] == PFRequestTypeSign) {
        [self startSignRequest];
    } else {
        [self startApprovalRequest];
    }
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

    DDLogDebug(@"DetailTableViewController::startApprovalRequest------\n%@\n------------------------------------------------------------\n", requestData);
    [wsController loadPostRequestWithData:requestData code:PFRequestCodeApprove];
    [wsController startConnection];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogDebug(@"DetailTableViewController::prepareForSegue sender=%@", [segue identifier]);

    if ([[segue identifier] isEqual:@"segueAttachments"]) {
        DDLogDebug(@"DetailTableViewController::prepareForSegue number of attachments=%lu", (unsigned long)[_dataSource.documents count]);

        AttachmentViewController *attachmentController = [segue destinationViewController];
        attachmentController.documentsDataSource = _dataSource.documents;
        attachmentController.attachedDocsDataSource = _dataSource.attachedDocs;
        [attachmentController setDetail:_dataSource];
        [attachmentController setRequestStatus:[PFHelper getPFRequestStatusFromString:_dataSourceRequest.view]];
    }

    if ([[segue identifier] isEqual:@"segueShowReceivers"]) {
        DDLogDebug(@"DetailTableViewController::prepareForSegue number of receivers=%lu", (unsigned long)[_dataSource.senders count]);
        ReceiversViewController *receiversController = [segue destinationViewController];
        receiversController.dataSource = _dataSource.signlines;
    }
}

- (void)loadDetailInfo
{
    self.referenceLbl.text = _dataSource.ref;
    self.inputDateLbl.text = _dataSource.date;
    [self showExpirationDateIfExists];
    [self showSubject];
    [self showApplication];
    [self showRejectExplanationIfExists];
    self.signLinesTypeLbl.text = _dataSource.signlinestype;
    NSString *requestTypeText = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? NSLocalizedString(@"Request_Type_Firma", nil) : NSLocalizedString(@"Request_Type_Visto_Bueno", nil);
    self.requestTypeLbl.text = requestTypeText;
    [self showSenders];
    _selectedRows = nil;
    PFRequest *detailRequest = [[PFRequest alloc] initWithId:_requestId];
    detailRequest.documents = _dataSource.documents;
    _selectedRows = [[NSArray alloc] initWithObjects:detailRequest, nil];
    
}

// Hide or show the expiration date
- (void)showExpirationDateIfExists
{
    //Next line is created to test an expiration date until the server works.
    self.inputExpirationDateLbl.text = _dataSource.expdate;
    if (!_dataSource.expdate){
        [self.expirationTableViewCell setHidden: true];
        CGFloat expirationTableViewCellHeight =  _expirationTableViewCell.frame.size.height;
        for(UITableViewCell *cell in self.cellBehindExpirationDate) {
            [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y - expirationTableViewCellHeight, cell.frame.size.width, cell.frame.size.height)];
        }
    }
}
- (void)showSubject
{
    //Aling to the top the textviews for this Table View Cell
    [self.subjectTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.subjectTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.subjectTextView setTextContainerInset:UIEdgeInsetsZero];
    self.subjectTextView.textContainer.lineFragmentPadding = 0;
    
    self.subjectTextView.text = _dataSource.subj;
    // Scroll to the top
    [self.subjectTextView scrollRangeToVisible:NSMakeRange(0,0)];
}

- (void)showApplication
{
    //Aling to the top the textviews for this Table View Cell
    [self.applicationTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.applicationTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.applicationTextView setTextContainerInset:UIEdgeInsetsZero];
    self.applicationTextView.textContainer.lineFragmentPadding = 0;
    
    self.applicationTextView.text = _dataSource.app;
    // Scroll to the top
    [self.applicationTextView scrollRangeToVisible:NSMakeRange(0,0)];
}

// Hide or show the reject explanation
- (void)showRejectExplanationIfExists
{
    self.rejectLbl.text = _dataSource.rejt;
    // Avoid the strings only with whitespaces. By default from the server the reject object is @" " (length == 1)
    NSString* trimmedTextString = [_dataSource.rejt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!_dataSource.rejt || [trimmedTextString length]==0 ){
        [self.rejectExplanationTableViewCell setHidden: true];
        CGFloat expirationTableViewCellHeight =  _expirationTableViewCell.frame.size.height;
        for(UITableViewCell *cell in self.cellBehindRejectExplanation) {
            [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y - expirationTableViewCellHeight, cell.frame.size.width, cell.frame.size.height)];
        }
    }
}

- (void)showSenders
{
    //Aling to the top the textviews for this Table View Cell
    [self.sendersTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.sendersTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTextView.textContainer.lineFragmentPadding = 0;
    
    NSMutableArray* senders = _dataSource.senders;
    NSString *joinedSenders = [senders componentsJoinedByString:@"\r"];
    self.sendersTextView.text = joinedSenders;
    // Scroll to the top
    [self.sendersTextView scrollRangeToVisible:NSMakeRange(0,0)];
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
    [SVProgressHUD dismiss];
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
        [self didReceiveParserWithError:@"Se ha producido un error de conexión con el servidor"];
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
        if ([[request status] isEqualToString:@"KO"]) {
            [self didReceiveError:[[NSString alloc] initWithFormat:@"Error al procesar la petición con codigo:%@", [request rejectid]]];
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
    [_documentActionSheet dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceivedRejectionResponse:(NSData *)responseData
{
    
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:responseData];
    RejectXMLController *parser = [[RejectXMLController alloc] initXMLParser];
    
    [nsXmlParser setDelegate:parser];
    BOOL success = [nsXmlParser parse];
    [SVProgressHUD dismiss];
    
    if (success) {
        NSArray *rejectsReq = [parser dataSource];
        [self didReceiveRejectResult:rejectsReq];
    }
    else {
        [self didReceiveError:@"Se ha producido un error de conexión con el servidor (501)"];
    }
}

- (void)didReceiveApprovalResult:(NSArray *)approvedRequests
{
    NSMutableArray *idsForRequestsWithError = [@[] mutableCopy];

    [approvedRequests enumerateObjectsUsingBlock:^(PFRequest *request, NSUInteger idx, BOOL *stop) {
         if ([request.status isEqualToString:@"KO"]) {
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
            errorMessage = [NSString stringWithFormat:@"Error al procesar la petición con código:%@", idsForRequestsWithError[0]];
        } else {
            NSMutableString *errorIDSString = [@"" mutableCopy];
            [idsForRequestsWithError enumerateObjectsUsingBlock:^(NSString *requestID, NSUInteger idx, BOOL *stop) {
                 [errorIDSString appendFormat:@" %@", requestID];
             }];
            errorMessage = [NSString stringWithFormat:@"Error al procesar las peticiones con códigos:%@", errorIDSString];
        }
        [self didReceiveError:errorMessage];
        [self dismissSelfView];
    }

    [_documentActionSheet dismissViewControllerAnimated:YES completion:nil];

}

- (void)didFinisParsingWithParser:(DetailXMLController *)parser
{
    BOOL finishOK = ![parser finishWithError];
    if (!finishOK) {
        NSString *errorCode = [parser errorCode] == nil ? @"" : [parser errorCode];
        NSString *err = [parser err] == nil ? @"" : [parser err];
        [self didReceiveError: [NSString stringWithFormat: @"Mensaje del servidor:%@(%@)", err, errorCode]];
        [_requestSignerController didReceiveParserWithError: [NSString stringWithFormat: @"Mensaje del servidor:%@(%@)", err, errorCode]];
    } else {
        DDLogDebug(@"DetailTableViewController:: Parsing Detail XML message with no errors ");
        _dataSource = [parser dataSource];
        [self loadDetailInfo];
    }
}

- (void)didReceiveError:(NSString *)errorString
{
    [SVProgressHUD dismiss];
    DDLogDebug(@"UnassignedRequestTableViewController::didReceiveParserWithError: %@", errorString);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert_View_Error", nil) message:errorString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - RequestSignerEvent

- (void)didReceiveSignerRequestResult:(NSArray *)requestsSigned
{
    DDLogDebug(@"ModalSignerController::didReceiveSignerRequestResult");
    [SVProgressHUD dismiss];

    BOOL processedOK = YES;
    NSString *msg = @"";

    for (PFRequest *request in requestsSigned) {
        if ([[request status] isEqualToString:@"KO"]) {
            if (![msg isEqualToString:@""]) {
                msg = @"Ocurrio un error al firmar algunas de las peticiones seleccionadas.";
                break;
            } else {
                msg = @"Ocurrio un error al firmar la peticion seleccionada";
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
    [_documentActionSheet dismissViewControllerAnimated:YES completion:nil];
    [(BaseListTVC *)self.navigationController.previousViewController refreshInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Handle rotation for this view

// When the device rotates we need to re-adapt the cells below the expiration date cell if it doesn't exist.
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
        [self showExpirationDateIfExists];
}

@end
