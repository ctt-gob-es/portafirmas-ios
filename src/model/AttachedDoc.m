//
//  AttachedDoc.m
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 9/1/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "AttachedDoc.h"

@implementation AttachedDoc

static NSString *const kDocumentMimeTypePDF = @"application/pdf";

- (void)prepareForRequestWithCode:(PFRequestCode)code
{
    switch (code) {
        case PFRequestCodeDocumentPreviewReport:
            _mmtp = kDocumentMimeTypePDF;
            break;
        default:
            break;
    }
}

@end
