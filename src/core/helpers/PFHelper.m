//
//  PFHelper.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 9/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "PFHelper.h"
#import "Source.h"

static NSString *const kPFHelperClassNameSignedList = @"ProcessedRequestViewController";
static NSString *const kPFHelperClassNameRejectedList = @"RejectedRequestViewController";
static NSString *const kPFHelperClassNamePendingList = @"UnassignedRequestTableViewController";

@implementation PFHelper

+ (PFRequestType)getPFRequestTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"FIRMA"]) {
        return PFRequestTypeSign;
    } else if ([string isEqualToString:@"VISTOBUENO"]) {
        return PFRequestTypeApprove;
    }
    return PFRequestTypeApprove;
}

+ (PFRequestStatus)getPFRequestStatusFromString:(NSString *)string
{
    if ([string isEqualToString:@"DEVUELTO"]) {
        return PFRequestStatusRejected;
    } else if ([string isEqualToString:@"FIRMADO"]) {
        return PFRequestStatusSigned;
    }
    return PFRequestStatusPending;
}

+ (PFRequestStatus)getPFRequestStatusFromClass:(Class)classObject
{
    NSString *className = NSStringFromClass(classObject);

    if ([className isEqualToString:kPFHelperClassNameSignedList]) {
        return PFRequestStatusSigned;
    } else if ([className isEqualToString:kPFHelperClassNameRejectedList]) {
        return PFRequestStatusRejected;
    } else if ([className isEqualToString:kPFHelperClassNamePendingList]) {
        return PFRequestStatusPending;
    }
	return PFRequestStatusPending;
}

+ (PFRequestCode)getPFRequestCodeForSection:(NSInteger)section
{
    switch (section) {
        case PFAttachmentVCSectionDocuments:
            return PFRequestCodeDocumentPreview;
        case PFAttachmentVCSectionSignatures:
            return PFRequestCodeDocumentPreviewSign;
        case PFAttachmentVCSectionSignaturesReport:
            return PFRequestCodeDocumentPreviewReport;
        case PFAttachmentVCSectionAttachedDocs:
            return PFRequestCodeDocumentPreview;
    }
	return PFRequestCodeDocumentPreview;
}

+ (NSString *)getPFSortCriteriaValueForRow:(PFSortPickerRow)row
{
    switch (row) {
        case PFSortPickerRowDate:

            return kPFFilterValueSortCriteriaDate;
        case PFSortPickerRowSubject:

            return kPFFilterValueSortCriteriaSubject;
        case PFSortPickerRowApp:

            return kPFFilterValueSortCriteriaApp;
        default:

            return nil;
    }
}

@end

