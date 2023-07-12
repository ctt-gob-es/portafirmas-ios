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
    docSource.title = @"Document_Section".localized;
    docSource.type = PFAttachmentTypeDocument;
    docSource.subType = PFAttachmentVCSectionDocuments;
    docSource.elements = _documentsDataSource.count;
    
    [sections addObject:docSource];
    
    if (_detail && _detail.type == PFRequestTypeSign && _requestStatus == PFRequestStatusSigned) {
        
        Source *docSignSource = [Source new];
        docSignSource.title =  @"Sign_Section".localized;
        docSignSource.type = PFAttachmentTypeDocument;
        docSignSource.subType = PFAttachmentVCSectionSignatures;
        docSignSource.elements = _documentsDataSource.count;
        
        Source *docReportSignSource = [Source new];
        docReportSignSource.title = @"Sign_Report_Section".localized;
        docReportSignSource.type = PFAttachmentTypeDocument;
        docReportSignSource.subType = PFAttachmentVCSectionSignaturesReport;
        docReportSignSource.elements = _documentsDataSource.count;
        
        [sections addObject:docSignSource];
        [sections addObject:docReportSignSource];
    }
    
    if (_attachedDocsDataSource != nil && _attachedDocsDataSource.count > 0) {
        Source *attachedDocSource = [Source new];
        attachedDocSource.title = @"Annexes_Section".localized;
        attachedDocSource.type = PFAttachmentTypeAttachedDoc;
        attachedDocSource.subType = PFAttachmentVCSectionAttachedDocs;
        attachedDocSource.elements = _attachedDocsDataSource.count;
        
        [sections addObject:attachedDocSource];
    }
    return sections;
}

#pragma mark TableViewDelegate
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

    // Returns the swipe actions to display on the trailing edge of the row
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *shareAction = self.configureShareAction;
    UIContextualAction *downloadAction = self.configureDownloadAction;
    
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[shareAction, downloadAction]];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    return swipeActionConfig;
}

    // Function to configure the share action
- (UIContextualAction *) configureShareAction {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
        title:@"Attachment_View_Share_Option".localized
        handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            // TODO complete
        completionHandler(YES);
    }];
    action.backgroundColor = [UIColor purpleColor];
    action.image = [UIImage systemImageNamed:@"square.and.arrow.up"];
    
    return action;
}

    // Function to configure the download action
- (UIContextualAction *) configureDownloadAction {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
        title:@"Attachment_View_Download_Option".localized
        handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            // TODO complete
        completionHandler(YES);
    }];
    action.backgroundColor = [UIColor orangeColor];
    action.image = [UIImage systemImageNamed:@"folder"];
    
    return action;
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
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if ([segue.identifier isEqualToString:@"segueShowPreview"]) {
        
        PreviewViewController *previewViewController = [segue destinationViewController];
        Source *sourceSection = [[self sections] objectAtIndex:selectedIndexPath.section];
        PFRequestCode requestCode = [PFHelper getPFRequestCodeForSection:sourceSection.subType];
        
        if (sourceSection.type == PFAttachmentTypeDocument) {
            Document *selectedDoc = _documentsDataSource[selectedIndexPath.row];
            [selectedDoc prepareForRequestWithCode:requestCode];
            [previewViewController setDocId:selectedDoc.docid];
            previewViewController.requestCode = requestCode;
            previewViewController.documentDataSource = selectedDoc;
            
        } else {
            AttachedDoc *selectedDoc = _attachedDocsDataSource[selectedIndexPath.row];
            [previewViewController setDocId:selectedDoc.docid];
            previewViewController.requestCode = requestCode;
            previewViewController.attachedDataSource = selectedDoc;
        }
    }
}

@end
