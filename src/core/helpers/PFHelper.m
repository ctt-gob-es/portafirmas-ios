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

+ (NSString *)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSMutableArray *)getYearsForFilter {
    NSMutableArray *yearsArray = [NSMutableArray new];
    NSInteger currentYear = [[self getCurrentYear] integerValue];
    for (int year = kPFInitialYearForFilters; year<=currentYear; year++) {
        [yearsArray insertObject:[@(year) stringValue] atIndex:0];
    }
    return yearsArray;
}

+ (NSString *)getDocumentNameBasedOnSection: (NSInteger)section originalDocumentName:(NSString *)originalDocumentName documentExtension: (NSString *)documentExtension
{
    NSString * finalDocumentName = originalDocumentName;
    switch (section) {
        case PFAttachmentVCSectionDocuments:
            finalDocumentName = originalDocumentName;
            break;
        case PFAttachmentVCSectionSignatures:
            finalDocumentName = [NSString stringWithFormat:@"%@_firmado.%@", originalDocumentName, documentExtension];
            break;
        case PFAttachmentVCSectionSignaturesReport:
            finalDocumentName = [NSString stringWithFormat:@"report_%@.pdf", originalDocumentName];
            break;
        case PFAttachmentVCSectionAttachedDocs:
            finalDocumentName = originalDocumentName;
            break;
    }
    return finalDocumentName;
}

@end

