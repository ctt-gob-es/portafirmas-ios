//
//  AttachmentViewController.m
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import "AttachmentViewController.h"
#import "PreviewViewController.h"
#import "Document.h"
#import "AttachedDoc.h"
#import "Source.h"

@interface AttachmentViewController ()

@end

@implementation AttachmentViewController
@synthesize documentsDataSource = _documentsDataSource;
@synthesize attachedDocsDataSource = _attachedDocsDataSource;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Custom initialization
    self.navigationController.toolbarHidden = YES;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) sections {
    NSMutableArray *sections = [NSMutableArray new];
    
    Source *docSource = [Source new];
    docSource.title = @"Documentos";
    docSource.type = PFAttachmentTypeDocument;
    docSource.subType = PFAttachmentVCSectionDocuments;
    docSource.elements = _documentsDataSource.count;
    
    [sections addObject:docSource];
    
    if (_detail && _detail.type == PFRequestTypeSign && _requestStatus == PFRequestStatusSigned) {
        
        Source *docSignSource = [Source new];
        docSignSource.title = @"Firmas";
        docSignSource.type = PFAttachmentTypeDocument;
        docSignSource.subType = PFAttachmentVCSectionSignatures;
        docSignSource.elements = _documentsDataSource.count;
        
        Source *docReportSignSource = [Source new];
        docReportSignSource.title = @"Informes de firmas";
        docReportSignSource.type = PFAttachmentTypeDocument;
        docReportSignSource.subType = PFAttachmentVCSectionSignaturesReport;
        docReportSignSource.elements = _documentsDataSource.count;
        
        [sections addObject:docSignSource];
        [sections addObject:docReportSignSource];
    }
    
    if (_attachedDocsDataSource != nil && _attachedDocsDataSource.count > 0) {
        Source *attachedDocSource = [Source new];
        attachedDocSource.title = @"Anexos";
        attachedDocSource.type = PFAttachmentTypeAttachedDoc;
        attachedDocSource.subType = PFAttachmentVCSectionAttachedDocs;
        attachedDocSource.elements = _attachedDocsDataSource.count;
        
        [sections addObject:attachedDocSource];
    }
    return sections;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self sections].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Source *sourceSection = [[self sections] objectAtIndex:section];
    return sourceSection.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   Source *sourceSection = [[self sections] objectAtIndex:section];
   return sourceSection.elements;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"AttachmentViewController::cellForRowAtIndexPath row=%ld", (long)[indexPath row]);

    static NSString *CellIdentifier = @"AttachmentsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    Source *sourceSection = [[self sections] objectAtIndex:indexPath.section];
    
    if (sourceSection.type == PFAttachmentTypeDocument) {
        [self configureCell:cell forDocument:_documentsDataSource[indexPath.row] ofType:sourceSection.type ofSubType:sourceSection.subType];
       
    } else {
         [self configureCell:cell forDocument:_attachedDocsDataSource[indexPath.row] ofType:sourceSection.type ofSubType:sourceSection.subType];
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forDocument:(id)item ofType:(PFAttachmentType)type ofSubType:(PFAttachmentVCSection)subType
{
    
    Document *document;
    AttachedDoc *attachedDoc;
    
    switch (type) {
        case PFAttachmentTypeDocument:
            document = (Document *) item;
            break;
            
        case PFAttachmentTypeAttachedDoc:
            attachedDoc = (AttachedDoc *) item;
            break;
    }
    
    switch (subType) {
        case PFAttachmentVCSectionDocuments:
            [cell.textLabel setText:document.nm];
            break;
            
        case PFAttachmentVCSectionSignatures:
            [cell.textLabel setText:[NSString stringWithFormat:@"%@_firmado.%@", document.nm, [document getSignatureExtension]]];
            break;
        case PFAttachmentVCSectionSignaturesReport:
            [cell.textLabel setText:[NSString stringWithFormat:@"report_%@.pdf", document.nm]];
            break;
        case PFAttachmentVCSectionAttachedDocs:
            [cell.textLabel setText:attachedDoc.nm];
            break;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogDebug(@"AttachmentViewController::prepareForSegue identifier=%@", [segue identifier]);
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    if ([segue.identifier isEqualToString:@"segueShowPreview"]) {

        PreviewViewController *previewViewController = [segue destinationViewController];
        // Configure the cell...
        Document *selectedDoc = _documentsDataSource[selectedIndexPath.row];
        DDLogDebug(@"AttachmentViewController::prepareForSegue document Id:%@", [selectedDoc docid]);

        PFRequestCode requestCode = [PFHelper getPFRequestCodeForSection:selectedIndexPath.section];
        [selectedDoc prepareForRequestWithCode:requestCode];
        [previewViewController setRequestCode:requestCode];
        [previewViewController setDocId:selectedDoc.docid];
        [previewViewController setDataSource:selectedDoc];
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

@end
