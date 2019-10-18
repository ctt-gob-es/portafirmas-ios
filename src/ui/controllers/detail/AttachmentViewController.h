//
//  AttachmentViewController.h
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Detail.h"

@interface AttachmentViewController : UITableViewController
{
    NSMutableArray *_documentsDataSource;
    NSMutableArray *_attachedDocsDataSource;
}

@property (strong, nonatomic) NSMutableArray *documentsDataSource;
@property (strong, nonatomic) NSMutableArray *attachedDocsDataSource;
@property (strong, nonatomic) Detail *detail;
@property (assign, nonatomic) PFRequestStatus requestStatus;

@end
