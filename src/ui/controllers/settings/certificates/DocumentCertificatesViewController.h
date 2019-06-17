//
//  DocumentCertificatesViewController.h
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 19/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertificateUtils.h"
#include "ModalCertificatesController.h"

@interface DocumentCertificatesViewController : PFBaseTVC <ModalCertificatesControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate> {

    NSString *_infoLabel;
    NSArray *files;
    NSString *_selectedCertificate;
    NSString *_password;
    BOOL waitingForDelete;
    BOOL watingForRegister;
	BOOL availableCertificates;
}
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstOptionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstOptionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondOptionTitleLabel;

// Find files in Document directory
- (NSArray *)findFiles:(NSArray *)extensions;
- (CGFloat)getLabelHeight:(UILabel*)label;
@end
