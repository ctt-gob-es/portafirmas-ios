//
//  AttachmentViewController.h
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Detail.h"
#import "WSDataController.h"

@interface AttachmentViewController : UITableViewController<WSDelegate>
{
    NSMutableArray *_documentsDataSource;
    NSMutableArray *_attachedDocsDataSource;
    WSDataController *dataController;
}

@property (strong, nonatomic) NSMutableArray *documentsDataSource;
@property (strong, nonatomic) NSMutableArray *attachedDocsDataSource;
@property (strong, nonatomic) Detail *detail;
@property (assign, nonatomic) PFRequestStatus requestStatus;
// TODO test
@property (assign, nonatomic) PFRequestCode requestCode;
@property (strong, nonatomic) NSString *docId;
@property (strong, nonatomic) NSString *docName;

@end
