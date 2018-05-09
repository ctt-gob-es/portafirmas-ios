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
    UIActionSheet *_documentActionSheet;
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
    NSString *signButtonTitle = [(PFRequest *)_dataSource type] == PFRequestTypeSign ? @"Firmar" : @"Visto Bueno";

    _documentActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancelar"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Rechazar", signButtonTitle, nil];

    [_documentActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case PFDocumentActionReject:
            [self rejectAction];
            break;

        case PFDocumentActionSign:
            [self signAction];
            break;

        case PFDocumentActionCancel:
            DDLogDebug(@"Cancel Action....");
            break;

        default:
            break;
    }
}

- (void)rejectAction
{
    DDLogDebug(@"Reject Action....");
    // Preguntamos el por qué del rechazo
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Rechazo de peticiones" message:@"Indique el motivo del rechazo" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continuar", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Motivo del rechazo";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    motivoRechazo = [[alertView textFieldAtIndex:0] text];
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    if (buttonIndex == [alertView cancelButtonIndex]) {
        // DO anything
        NSLog(@"El usuario ha clicado en la opción cancelar");
    }
    else {
        
        DDLogDebug(@"UnassignedRequestTableViewController::Reject request....Selected rows=%lu", (unsigned long)[_selectedRows count]);
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        
        NSString *data = [RejectXMLController buildRequestWithIds:_selectedRows motivoR: motivoRechazo];
        DDLogDebug(@"UnassignedRequestTableViewController::rejectRequest input Data=%@", data);
        
        _waitingResponseType = PFWaitingResponseTypeRejection;
        [wsController loadPostRequestWithData:data code:PFRequestCodeReject];
        [wsController startConnection];
    }
}

- (void)signAction
{
    DDLogDebug(@"Sign Action....\nAccept request....Selected rows=%lu", (unsigned long)[_selectedRows count]);

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

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
    [self.subjectTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.subjectTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.subjectTextView setTextContainerInset:UIEdgeInsetsZero];
    self.subjectTextView.textContainer.lineFragmentPadding = 0;
    self.subjectTextView.text = _dataSource.subj;
}

- (void)showApplication
{
    [self.applicationTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.applicationTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.applicationTextView setTextContainerInset:UIEdgeInsetsZero];
    self.applicationTextView.textContainer.lineFragmentPadding = 0;
    self.applicationTextView.text = _dataSource.app;
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
    [self.sendersTitleTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTitleTextView.textContainer.lineFragmentPadding = 0;
    [self.sendersTextView setTextContainerInset:UIEdgeInsetsZero];
    self.sendersTextView.textContainer.lineFragmentPadding = 0;
    NSMutableArray* senders = _dataSource.senders;
    [senders addObject:@"Second sender"];
    [senders addObject:@"Second sender"];
    [senders addObject:@"Second sender"];
//    [senders addObject:@"Second sender"];

    NSString *joinedSenders = [senders componentsJoinedByString:@"\r"];
    self.sendersTextView.text = joinedSenders;
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
        // @" Peticiones rechazadas corrrectamente"
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INFO", @"")
                                    message:@"Peticiones rechazadas correctamente"
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
    }

    [_documentActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INFO", @"")
                                    message:@"Peticiones procesadas correctamente"
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
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
    }

    [_documentActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                message:errorString
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INFO", @"")
                                    message:@"Peticiones firmadas correctamente"
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
    } else {
        [self didReceiveError:msg];
    }

    [_documentActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [(BaseListTVC *)self.navigationController.previousViewController refreshInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (isSuccessReject) {
        isSuccessReject = NO;
        [(BaseListTVC *)self.navigationController.previousViewController refreshInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Handle rotation for this view

// When the device rotates we need to re-adapt the cells below the expiration date cell if it doesn't exist.
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
        [self showExpirationDateIfExists];
}

@end
