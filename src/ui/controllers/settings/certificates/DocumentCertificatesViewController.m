//
//  DocumentCertificatesViewController.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 19/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "DocumentCertificatesViewController.h"
#import "CertificateUtils.h"

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
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _selectedCertificate = nil;
    files = [self findFiles:[NSArray arrayWithObjects:@"p12", @"pfx", nil]];

    if ([files count ] == 0) {
        _messageView.text = @"La aplicación esta solicitando acceso a su almacen de certificados y no dispone de ninguno registrado.\n\n  Para instalar su certificado :\n 1. Conecte su dispositivo a su PC o Mac.\n 2. Localice el certificado que desea instalar ....(debe conocer el pin del certificado)\n3. En iTunes seleccione su certificado y arrástrelo a la ventana de documentos...\n4. Vuelva a esta pantalla y registrelo en el almacen del dispositivo.\n";
        [_messageView sizeToFit];
    }

    // Tabulacion de la tabla
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 10, -30);
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

	[self setButtonStyle];

}

// Style methods
- (void)setButtonStyle {
	if (@available(iOS 11, *)) {
		// Change height for messageView to include the button
		self.messageView.frame = CGRectMake(self.messageView.frame.origin.x, self.messageView.frame.origin.y, self.messageView.frame.size.width, self.messageView.frame.size.height + kFilesAppButtonNormalHeight);
		UIButton *filesAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[filesAppButton addTarget:self action:@selector(filesAppButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[filesAppButton setTitle:NSLocalizedString(@"files_app_button", nil) forState:UIControlStateNormal];
		
		filesAppButton.frame = CGRectMake(0, (self.messageView.frame.origin.y + self.messageView.frame.size.height - kFilesAppButtonNormalHeight), self.view.frame.size.width, kFilesAppButtonNormalHeight);
		[filesAppButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[self.view addSubview:filesAppButton];
	} else {
//	self.filesAppButton.frame =
	}
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
        files = [self findFiles:[NSArray arrayWithObjects:@"p12", @"pfx", nil]];
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
		if ([fileType  isEqualToString: @"p12"] || [fileType  isEqualToString: @"pfx"]) {
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
			files = [self findFiles:@[@"p12", @"pfx"]];
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
