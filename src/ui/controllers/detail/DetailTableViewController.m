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
    Application
} CellTypes;

NSInteger *const numberOfRows = 11;
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

- (void)viewWillAppear:(BOOL)animated
{
    DDLogDebug(@"DetailTableViewController::viewWillAppear");
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    self.tableView.estimatedRowHeight = defaultCellHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"DetailCell" bundle:nil] forCellReuseIdentifier:@"detailCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    }
    NSString *title = @"";
    NSString *value = @"";
    switch (indexPath.row) {
        case From:
            title = @"De: ";
            value = [self getSenders];
            [cell setDarkStyle];
            break;
        case Subject:
            title = @"Asunto: ";
            value = [self getSubject];
            [cell setDarkStyle];
            [cell setValueBoldStyle];
            break;
        case Reference:
            self.referenceLbl.text = _dataSource.ref;
            title = @"Referencia: ";
            value = [self getReference];
            [cell setDarkStyle];
            break;
        case RejectExplanation:
            title = @"Motivo del rechazo: ";
            value = [self getRejectExplanation];
            [cell setDarkStyle];
            [cell increaseTitleLabelWidth: rejectCellTitleCellWidth];
            [cell hideLabelsIfNeeded: ![self rejectExplanationExists]];
            break;
        case AttachedDocument:
            title = @"Documentos adjuntos";
            [cell setValueInNewViewStyle];
            [cell increaseTitleLabelWidth:largeTitleCellWidth];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case Receivers:
            title = @"Destinatarios";
            [cell setValueInNewViewStyle];
            [cell increaseTitleLabelWidth: largeTitleCellWidth];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case RequestType:
            title = @"Operación: ";
            value = [self getRequestType];
            [cell setClearStyle];
            [cell setValueBoldStyle];
            break;
        case SignType:
            title = @"Tipo de firma: ";
            value = [self getSignType];
            [cell setClearStyle];
            break;
        case Date:
            title = @"Fecha: ";
            value = [self getDate];
            [cell setClearStyle];
            break;
        case ExpirationDate:
            title = @"Expira: ";
            value = [self getExpirationDate];
            [cell setClearStyle];
            [cell hideLabelsIfNeeded: !_dataSource.expdate];
            break;
        case Application:
            title = @"Aplicación: ";
            value = [self getApplication];
            [cell setClearStyle];
            break;
    }
    [cell setCellTitle: title];
    [cell setCellValue: value];
    return cell;
}

-(NSString *)getSenders
{
    NSMutableArray* senders = _dataSource.senders;
    return [senders componentsJoinedByString:@"\r"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

    switch (indexPath.row) {
        case AttachedDocument: {
            AttachmentViewController *attachmentController =  (AttachmentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AttachmentsListView"];
            attachmentController.documentsDataSource = _dataSource.documents;
            attachmentController.attachedDocsDataSource = _dataSource.attachedDocs;
            [attachmentController setDetail:_dataSource];
            [attachmentController setRequestStatus:[PFHelper getPFRequestStatusFromString:_dataSourceRequest.view]];
            [self.navigationController pushViewController:attachmentController animated:YES];
            break;
        }
        case Receivers: {
            ReceiversViewController *receiversController =  (ReceiversViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ReceiversListView"];
            receiversController.dataSource = _dataSource.signlines;
            [self.navigationController pushViewController:receiversController animated:YES];
            break;
        }
    }
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

- (void)loadDetailInfo
{
    self.applicationTextView.text = _dataSource.app;
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
    }
    return tableView.rowHeight;
}

- (BOOL)rejectExplanationExists
{
    // Avoid the strings only with whitespaces. By default from the server the reject object is @" " (length == 1)
    NSString* trimmedTextString = [_dataSource.rejt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (_dataSource.rejt && [trimmedTextString length] != 0);
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
        [self.tableView reloadData];
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

@end
