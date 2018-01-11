//
//  Source.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 9/1/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, PFAttachmentVCSection)
{
    PFAttachmentVCSectionDocuments,
    PFAttachmentVCSectionSignatures,
    PFAttachmentVCSectionSignaturesReport,
    PFAttachmentVCSectionAttachedDocs
};

typedef NS_ENUM (NSInteger, PFAttachmentType)
{
    PFAttachmentTypeDocument,
    PFAttachmentTypeAttachedDoc
};


@interface Source : NSObject
@property (strong, nonatomic) NSString *title;
@property (nonatomic) PFAttachmentType type;
@property (nonatomic) PFAttachmentVCSection subType;
@property (nonatomic) NSInteger elements;
@end
