//
//  DocumentCertificatesViewController.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 19/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "DocumentCertificatesViewController.h"
#import "CertificateUtils.h"
#import "GlobalConstants.h"

@interface DocumentCertificatesViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editBarButtonItem;

@end

@implementation DocumentCertificatesViewController

int const kFilesAppButtonNormalHeight = 40;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    return self;
}

// Custom initialization using story board
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        waitingForDelete = NO;
        watingForRegister = NO;
		availableCertificates = NO;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _selectedCertificate = nil;
    files = [self findFiles:[NSArray arrayWithObjects:P12EXTENSION, PFXEXTENSION, nil]];

    if ([files count ] != 0) {
		availableCertificates = YES;
    }

    // Tabulacion de la tabla
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 10, -30);
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

	// Styles
	self.navigationItem.title = NSLocalizedString(@"available_certificates", nil);
	[self setMessageStyle];
	[self setButtonStyle];


}

// Style methods
- (void)setButtonStyle {
	if (@available(iOS 11, *)) {

		if (!availableCertificates) {
			self.messageContainerView.frame = CGRectMake(self.messageContainerView.frame.origin.x, self.messageContainerView.frame.origin.y, self.messageContainerView.frame.size.width, 16 + [self getLabelHeight:self.descriptionLabel] + 16 + [self getLabelHeight:self.firstOptionTitleLabel] + 8 + [self getLabelHeight:self.firstOptionDescriptionLabel] + 16 + [self getLabelHeight:self.secondOptionTitleLabel] + kFilesAppButtonNormalHeight);
		} else {
			self.messageContainerView.frame = CGRectMake(self.messageContainerView.frame.origin.x, self.messageContainerView.frame.origin.y, self.messageContainerView.frame.size.width, 16 + [self getLabelHeight:self.descriptionLabel] + kFilesAppButtonNormalHeight);
		}
		UIButton *filesAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[filesAppButton addTarget:self action:@selector(filesAppButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[filesAppButton setTitle:NSLocalizedString(@"files_app_button", nil) forState:UIControlStateNormal];
		filesAppButton.frame = CGRectMake(0, (self.messageContainerView.frame.origin.y + self.messageContainerView.frame.size.height - kFilesAppButtonNormalHeight), self.view.frame.size.width, kFilesAppButtonNormalHeight);
		[filesAppButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[self.view addSubview:filesAppButton];
	}
}
- (void)setMessageStyle {
	if (!availableCertificates) {
		[self.descriptionLabel setFont:[UIFont boldSystemFontOfSize:17]];
		self.descriptionLabel.text = NSLocalizedString(@"available_certificates_description_label", nil);
		self.firstOptionTitleLabel.text = NSLocalizedString(@"available_certificates_first_option_title_label", nil);
		self.firstOptionTitleLabel.hidden = false;
		self.firstOptionDescriptionLabel.text = NSLocalizedString(@"available_certificates_first_option_description_label", nil);
		self.firstOptionDescriptionLabel.hidden = false;
		self.secondOptionTitleLabel.text = NSLocalizedString(@"available_certificates_second_option_title_label", nil);
		self.secondOptionTitleLabel.hidden = false;
	} else {
		self.descriptionLabel.text = NSLocalizedString(@"available_certificates_description_when_available_certificates", nil);
		self.firstOptionTitleLabel.hidden = true;
		self.firstOptionDescriptionLabel.hidden = true;
		self.secondOptionTitleLabel.hidden = true;
	}
}

- (CGFloat)getLabelHeight:(UILabel*)label
{
	CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
	CGSize size;
	NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
	CGSize boundingBox = [label.text boundingRectWithSize:constraint
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:label.font}
												  context:context].size;
	size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
	return size.height;
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DDLogDebug(@"didReceiveMemoryWarning");

}

- (IBAction)didTapOnBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [files count];
}

// Configure the tableview cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CertificateFileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];

    cell.textLabel.text = [files objectAtIndex:[indexPath row]];

    return cell;
}

- (IBAction)didClickEditButton:(id)sender
{
    if ([files count] > 0) {
        [self editTable:!self.editing];
    }
}

- (void)editTable:(BOOL)edit
{
    [self setEditing:edit animated:NO];
    [self.tableView reloadData];
    [_editBarButtonItem setTitle:edit ? @"Hecho":@"Editar"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((self.editing) && ([files count] > 0)) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Eliminar";
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileToDelete = files[indexPath.row];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileToDelete];
        NSError *error;
        NSString *message;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        message = success ? NSLocalizedString(@"Alert_View_certificated_removed_correctly", nil) : NSLocalizedString(@"Alert_View_An_Error_Has_Ocurred", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
        files = [self findFiles:[NSArray arrayWithObjects:P12EXTENSION, PFXEXTENSION, nil]];
        [self.tableView reloadData];
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"didSelectRowAtIndexPath row=%ld", (long)[indexPath row]);

    _selectedCertificate = [files objectAtIndex:[indexPath row]];
}

// Find files in Document directory
- (NSArray *)findFiles:(NSArray *)extensions
{

#if TARGET_IPHONE_SIMULATOR

    NSMutableArray *arrayCertsMut = [[NSMutableArray alloc] init];

    [arrayCertsMut addObject:@"ANF_PF_Activo"];
    [arrayCertsMut addObject:@"PFActivoFirSHA1"];
    [arrayCertsMut addObject:@"pruebas_portafirmas"];

    return arrayCertsMut;

#else

    NSMutableArray *matches = [@[] mutableCopy];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    NSString *ext;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];

    // >>> this section here adds all files with the chosen extension to an array
    for (item in contents) {
        for (ext in extensions) {
            if ([[item pathExtension] isEqualToString:ext]) {
                [matches addObject:item];
            }
        }
    }

    return matches;

#endif /* if TARGET_IPHONE_SIMULATOR */
}

- (void)viewDidUnload
{
    [SVProgressHUD dismiss];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogDebug(@"DocumentCertificatesViewController::prepareForSegue identifier=%@", [segue identifier]);

    if ([segue.identifier isEqualToString:@"segueModalCertificates"]) {
        NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
        DDLogDebug(@"DocumentCertificatesViewController::prepareForSegue selected index=%ld", (long)[selectedRowIndexPath row]);

        // Sets data in Aplication delegate objet to be shared for the application's tab
        _selectedCertificate = [files objectAtIndex:[selectedRowIndexPath row]];
        ModalCertificatesController *modalController  = [segue destinationViewController];
        modalController.selectedCertificate = _selectedCertificate;
        modalController.modalPresentationStyle = 17;
        [modalController setDelegate:self];
    }
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

- (IBAction)filesAppButtonTapped:(id)sender {
	UIDocumentMenuViewController *documentProviderMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
	documentProviderMenu.delegate = self;
	documentProviderMenu.modalPresentationStyle = UIModalPresentationPopover;
	UIPopoverPresentationController *popPC = documentProviderMenu.popoverPresentationController;
	documentProviderMenu.popoverPresentationController.sourceRect = self.messageView.frame;
	documentProviderMenu.popoverPresentationController.sourceView = self.view;
	popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
	[self presentViewController:documentProviderMenu animated:YES completion:nil];
}

#pragma mark - ModalCertificatesControllerDelegate

- (void)certificateAdded
{
    [self didTapOnBackButton:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
	if (controller.documentPickerMode == UIDocumentPickerModeImport) {
		
		NSString* fileType = [url.lastPathComponent pathExtension];
		Boolean correctFileType = false ;
		NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"files_app_alert_message_incorrect_file", nil), [url lastPathComponent]];
		if ([fileType  isEqualToString: P12EXTENSION] || [fileType  isEqualToString: PFXEXTENSION]) {
			correctFileType = true;
		}
		
		if (correctFileType) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSError *copyError = nil;
			NSURL* documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
			NSURL* fileDirectory = [documentDirectory URLByAppendingPathComponent: url.lastPathComponent isDirectory:YES];
			[fileManager copyItemAtURL:url toURL: fileDirectory error:&copyError];
			if (!copyError)
			{
				alertMessage = [NSString stringWithFormat:NSLocalizedString(@"files_app_alert_message_success", nil), [url lastPathComponent]];
			}
			else
			{
				alertMessage = [NSString stringWithFormat:NSLocalizedString(@"files_app_alert_message_cannot_add_certificate", nil), [url lastPathComponent]];
			}
			files = [self findFiles:@[P12EXTENSION, PFXEXTENSION]];
			[self.tableView reloadData];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertController *alertController = [UIAlertController
												  alertControllerWithTitle: nil
												  message:alertMessage
												  preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"files_app_alert_affirmative_button", nil) style:UIAlertActionStyleDefault handler:nil]];
			[self presentViewController:alertController animated:YES completion:nil];
			
		});
	}
}

- (void)documentMenu:(nonnull UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(nonnull UIDocumentPickerViewController *)documentPicker {
	documentPicker.delegate = self;
	[self presentViewController:documentPicker animated:YES completion:nil];
}

@end
