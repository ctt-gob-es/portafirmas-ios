//
//  RequestTableViewController.m
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana on 22/10/12.
//  Copyright (c) 2012 Tempos21. All rights reserved.
//

#import "FilterVC.h"
#import "UnassignedRequestTableViewController.h"
#import "RequestListXMLController.h"
#import "RejectXMLController.h"
#import "DetailTableViewController.h"
#import "PFRequest.h"
#import "PFCellContentFactory.h"
#import "AppDelegate.h"
#import "RequestSignerController.h"
#import "PFRequestResult.h"
#import "RequestCell.h"
#import "RequestCellNoUI.h"
#import "ApproveXMLController.h"
#import "LoginService.h"
#import "userDNIManager.h"

#define TAB_BAR_HIDDEN_FRAME CGRectMake(-10, -10, 0, 0)

@interface UnassignedRequestTableViewController() <UIPopoverPresentationControllerDelegate>
{
    CGRect _tabBarFrame;
    CGRect _tabViewFrame;
    NSSet *_selectedRequestsSetToSign;
    NSSet *_selectedRequestSetToApprove;
    PFWaitingResponseType _waitingResponseType;
    BOOL _didSetUpTabBar, reject;
    NSString *motivoRechazo;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButtonItem;

@end

@implementation UnassignedRequestTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});

        self.dataStatus = kBaseListVCDataStatusPending;

        // Custom initialization
        [_signBarButton setEnabled:NO];
        [_rejectBarButton setEnabled:NO];

        // Sets data in Aplication delegate objet to be shared for the application's tab
        AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appConfig = myDelegate.appConfig;

        selectedRows = [@[] mutableCopy];
    }

    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setRightBarButtonItems:@[_filterButtonItem, self.navigationItem.rightBarButtonItem] animated:NO];
    [self assignMainTabToAppDelegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupTabBar];
    [self.parentViewController setHidesBottomBarWhenPushed:TRUE];
    [self.navigationController setToolbarHidden:YES];
    [self.parentViewController.tabBarController.tabBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
    [self.parentViewController setHidesBottomBarWhenPushed:TRUE];
    [self.navigationController setToolbarHidden:YES];
    [self.parentViewController.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) assignMainTabToAppDelegate {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController *nav = (UINavigationController *)self.presentingViewController;
	if (appDelegate.mainTab == nil) {
		if (nav != nil && nav.presentedViewController != nil) {
			UITabBarController *tabBarController = (UITabBarController *)nav.presentedViewController;
			if (tabBarController != nil) {
				appDelegate.mainTab = tabBarController;
			}
		}
	}
}

#pragma mark - Network Calls

- (void)loadData {
	_waitingResponseType = PFWaitingResponseTypeList;
    [super loadData];
}

- (IBAction)rejectAction:(id)sender {
    
    reject = YES;
    // Preguntamos el por qué del rechazo
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rejection_of_requests", nil) message:NSLocalizedString(@"Indicate_Reason_For_Rejection", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *conti = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self continueButtonClicked:alert];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Reason_For_Rejection", nil);
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    [alert addAction:cancel];
    [alert addAction:conti];
    [self presentViewController:alert animated:YES completion:nil];
        
}

- (IBAction)cancelAction:(id)sender
{
    [self cancelEditing];
}

- (void)startSendingSignRequests
{
    [self enableUserInteraction:false];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});

    requestSignerController = [RequestSignerController new];
    [requestSignerController setDelegate:self];
    [requestSignerController loadPreSignRequestsWithCurrentCertificate:_selectedRequestsSetToSign.allObjects];
}

- (void)startSendingApproveRequests
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    _waitingResponseType = PFWaitingResponseTypeApproval;
    NSString *requestData = [ApproveXMLController buildRequestWithRequestArray:_selectedRequestSetToApprove.allObjects];
    [self.wsDataController loadPostRequestWithData:requestData code:PFRequestCodeApprove];
    [self.wsDataController startConnection];
}


#pragma mark - User Interface

- (void)setupTabBar
{
    if (!_didSetUpTabBar) {
        [self.navigationController setTabBarItem:[self.tabBarItem initWithTitle:@"Pendientes"
                                                                          image:[[QuartzUtils getImageWithName:@"ic_pendientes" andTintColor:[UIColor lightGrayColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                  selectedImage:[[QuartzUtils getImageWithName:@"ic_pendientes" andTintColor:THEME_COLOR] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]]];
        _didSetUpTabBar = YES;
    }
    [self.navigationController setTitle:@"Pendientes"];
    [self.presentingViewController setTitle:@"Pendientes"];
    [self.navigationController.navigationItem setTitle:@"Pendientes"];
    [self.navigationItem setTitle:@"Pendientes"];
}

- (void)updateEditButtons
{
    BOOL enableButtons = selectedRows.count > 0;

    [_signBarButton setEnabled:enableButtons];
    [_rejectBarButton setEnabled:enableButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - User Interaction

- (IBAction)didTapOnBackButton:(id)sender
{
    
    //TODO Launch logout process if server has login support
    if ([LoginService instance].serverSupportLogin){
        
        [[LoginService instance] logout:^{
             [self closeView];
        } failure:^(NSError *error) {
             [self closeView];
        }];
        
    } else {
        [self closeView];
    }
}


- (IBAction)editAction:(id)sender
{
    if ([self.dataArray count] > 0) {
        [self setEditing: !self.editing animated: !self.editing];
    }
}

- (void) closeView {
	dispatch_async(dispatch_get_main_queue(), ^{
	   [self dismissViewControllerAnimated:YES completion:nil];
	});
}

- (IBAction)signAction:(id)sender
{
    [self separateSignAndApproveRequests];
    [self showSignApproveAlert];
}

- (void)separateSignAndApproveRequests
{
    NSSet *selectedRequestsSet = [NSSet setWithArray:selectedRows];

    _selectedRequestsSetToSign = [selectedRequestsSet objectsPassingTest:^BOOL (PFRequest *request, BOOL *stop) {
                                      return request.type == PFRequestTypeSign;
                                  }];
    _selectedRequestSetToApprove = [selectedRequestsSet objectsPassingTest:^BOOL (PFRequest *request, BOOL *stop) {
                                        return request.type == PFRequestTypeApprove;
                                    }];
}

- (void)showSignApproveAlert
{
    NSString *message;

    if (_selectedRequestSetToApprove && _selectedRequestSetToApprove.count > 0 && _selectedRequestsSetToSign && _selectedRequestsSetToSign.count > 0) {
        message = [NSString stringWithFormat:NSLocalizedString(@"Alert_View_Process_Sign_and_Approve", nil), (unsigned long)_selectedRequestsSetToSign.count, (unsigned long)_selectedRequestSetToApprove.count];
    }
    else if (_selectedRequestSetToApprove && _selectedRequestSetToApprove.count > 0) {
        message = [NSString stringWithFormat:NSLocalizedString(@"Alert_View_Process_Approve", nil), (unsigned long)_selectedRequestSetToApprove.count];
    }
    else if (_selectedRequestsSetToSign && _selectedRequestsSetToSign.count > 0) {
        message = [NSString stringWithFormat:NSLocalizedString(@"Alert_View_Process_Sign", nil), (unsigned long)_selectedRequestsSetToSign.count];
    }

    if (message) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert_View_Notice", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *conti = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self continueButtonClicked: alert];
        }];
        [alert addAction:cancel];
        [alert addAction:conti];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)enableUserInteraction: (BOOL)value {
    [self.parentViewController.view setUserInteractionEnabled:value];
}

- (void)continueButtonClicked: (UIAlertController *)alertController {
    if (reject) {
        reject = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD show];
		});

        if ([alertController.textFields count] != 0) {
            NSArray *textfields = alertController.textFields;
            UITextField *nameTextfield = textfields[0];
            motivoRechazo = nameTextfield.text;
        }
        NSString *data = [RejectXMLController buildRequestWithIds:selectedRows motivoR:motivoRechazo];
        _waitingResponseType = PFWaitingResponseTypeRejection;
        [self.wsDataController loadPostRequestWithData:data code:PFRequestCodeReject];
        [self.wsDataController startConnection];
    }
    else if (_selectedRequestsSetToSign && _selectedRequestsSetToSign.count > 0) {
        [self startSendingSignRequests];
    }
    else if (_selectedRequestSetToApprove && _selectedRequestSetToApprove.count > 0) {
        [self startSendingApproveRequests];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	if (![self isEditing]) {
		[theTableView deselectRowAtIndexPath:newIndexPath animated:true];
	}
	
    [self updateSelectionWithIndexPath:newIndexPath selected:YES];
}

- (void)tableView:(UITableView *)theTableView didDeselectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
    [self updateSelectionWithIndexPath:newIndexPath selected:NO];
}

- (void)updateSelectionWithIndexPath:(NSIndexPath *)newIndexPath selected:(BOOL)selected
{
    if ([self isEditing]) {
        selected ? [selectedRows addObject:self.dataArray[newIndexPath.row]] : [selectedRows removeObject:self.dataArray[newIndexPath.row]];
        [self updateEditButtons];
    }
}

#pragma mark - Navigation Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueDetail"]) {
        
        [self prepareForDetailSegue:segue enablingSigning:YES];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return (!([self isEditing]));
}

#pragma mark - Edit Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing: editing animated:animated];
    if (editing) {
        [_selectButtonItem setTitle:@"Hecho"];
		[self setEditingBottomBar];
        [self.tableView reloadData];
        selectedRows = [@[] mutableCopy];
    }
    else {
        
        [_selectButtonItem setTitle:@"Seleccionar"];
        [self setNormalBottomBar];

        if (!([selectedRows count] > 0)) {
            [_signBarButton setEnabled:NO];
            [_rejectBarButton setEnabled:NO];
        }

        [[self tableView] reloadData];
    }
}

- (void)setEditingBottomBar
{
    if (_tabBarFrame.size.width != self.tabBarController.tabBar.frame.size.width) {
        _tabBarFrame = self.tabBarController.tabBar.frame;
    }

    if (!CGRectIsEmpty(self.tabBarController.tabBar.frame)) {
        CGRect fullScreen = self.view.frame;
		fullScreen.size.height += self.tabBarController.tabBar.frame.size.height;
        [self.view setFrame:fullScreen];
        [self.tabBarController.tabBar setFrame:TAB_BAR_HIDDEN_FRAME];
        [self.navigationController setToolbarHidden:NO animated:YES];
		[self.parentViewController.tabBarController.tabBar setHidden:YES];
    }
}

- (void)setNormalBottomBar
{
	[self.parentViewController.tabBarController.tabBar setHidden:NO];
	//  if (_tabBarFrame.size.height > 0 && CGRectIsEmpty(self.tabBarController.tabBar.frame)) {
    if (_tabBarFrame.size.height > 0) {
        [self.navigationController setToolbarHidden:YES animated:YES];
        CGRect tabRect = self.view.frame;
        [self.view setFrame:tabRect];
        [self.tabBarController.tabBar setFrame:_tabBarFrame];
    }
}

- (void)cancelEditing
{
    [super setEditing:NO animated:NO];
    [self setEditing:NO animated:NO];
    [[self tableView] reloadData];
}

#pragma mark - WSDelegate

- (void)doParse:(NSData *)data
{
    if (_waitingResponseType == PFWaitingResponseTypeList) {
        [super doParse:data];
    }
    else if (_waitingResponseType == PFWaitingResponseTypeRejection) {
        [self didReceivedRejectionResponse:data];
    }
    else if (_waitingResponseType == PFWaitingResponseTypeApproval) {
        [self didReceivedApprovalResponse:data];
    }

    _waitingResponseType = nil;
    [self cancelEditing];
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
        [self didReceiveError:@"Se ha producido un error de conexión con el servidor (501)"];
    }
}

- (void)didReceivedApprovalResponse:(NSData *)responseData
{
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:responseData];
    ApproveXMLController *parser = [[ApproveXMLController alloc] init];

    [nsXmlParser setDelegate:parser];
    BOOL success = [nsXmlParser parse];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

    if (success) {
        NSArray *approvalRequests = [parser dataSource];
        [self handleApprovalRequests:approvalRequests];
    } else {
        [self didReceiveError:@"Se ha producido un error de conexión con el servidor (501)"];
    }
}

- (void)handleApprovalRequests:(NSArray *)approvalRequests
{
    NSMutableArray *idsForRequestsWithError = [@[] mutableCopy];

    [approvalRequests enumerateObjectsUsingBlock:^(PFRequest *request, NSUInteger idx, BOOL *stop) {
         if ([request.status isEqualToString:@"KO"]) {
             [idsForRequestsWithError addObject:request.reqid];
         }
     }];

    if (idsForRequestsWithError.count == 0) {
        // @" Peticiones firmadas corrrectamente"
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Alert_View_Request_Signed_Correctly", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
        
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

    [self cancelEditing];
    [self refreshInfo];
}

- (void)didReceiveSignerRequestResult:(NSArray *)requestsSigned
{
    [self enableUserInteraction: true];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

    NSIndexSet *requestsWithError = [requestsSigned indexesOfObjectsPassingTest:^BOOL (PFRequest *request, NSUInteger idx, BOOL *stop) {
                                         return [request.status isEqualToString:@"KO"];
                                     }];

    // Mostramos un mensaje modal con el resultado de la operacion
    if (requestsWithError.count == 0) {
        // Peticiones firmadas corrrectamente
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Alert_View_Everything_Signed_Correctly", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // Operacion finalizada con errores
        NSString *msg = requestsWithError.count == 1 ? (requestsSigned.count == 1 ?  NSLocalizedString(@"Alert_View_One_Signature_Failed_In_Single_Request", nil) : NSLocalizedString(@"Alert_View_One_Signature_Failed_In_Multilple_Request", nil)) : NSLocalizedString(@"Alert_View_Multiple_Signatures_Failed_In_Multiple_Request", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"")
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }

    if (_selectedRequestSetToApprove && _selectedRequestSetToApprove.count > 0) {
        [self startSendingApproveRequests];
    }
    else {
        [self cancelEditing];
        [self refreshInfo];
    }
}

- (void)didReceiveRejectResult:(NSArray *)requestsSigned
{
    BOOL processedOK = TRUE;
    for (PFRequestResult *request in requestsSigned) {
        if ([[request status] isEqualToString:@"KO"]) {
            NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"Alert_View_Error_When_Processing_Request", nil), [request rejectid]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
            processedOK = FALSE;
        }
    }

    if (processedOK) {
        
        _waitingResponseType = PFWaitingResponseTypeList;
        [super loadData];
        // Peticiones rechazadas corrrectamente
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                                                                 message:NSLocalizedString(@"Correctly_rejected_requests", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self cancelEditing];
}

#pragma mark - UIAlertViewDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    
    return UIModalPresentationNone;
}

@end
