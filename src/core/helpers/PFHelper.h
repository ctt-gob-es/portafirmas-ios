//
//  PFHelper.h
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 9/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, PFRequestType) {
    PFRequestTypeSign,
    PFRequestTypeApprove
};

typedef NS_ENUM (NSInteger, PFRequestStatus) {
    PFRequestStatusSigned,
    PFRequestStatusRejected,
    PFRequestStatusPending
};

typedef NS_ENUM (NSInteger, PFRequestCode) {
    PFRequestCodeList = 2,
    PFRequestCodeReject = 3,
    PFRequestCodeDocumentPreview = 5,
    PFRequestCodeAppList = 6,
    PFRequestCodeApprove = 7,
    PFRequestCodeDocumentPreviewSign = 8,
    PFRequestCodeDocumentPreviewReport = 9,
    PFRequestCodeValidate = 20
};

typedef NS_ENUM (NSInteger, PFWaitingResponseType) {
    PFWaitingResponseTypeList,
    PFWaitingResponseTypeRejection,
    PFWaitingResponseTypeApproval,
    PFWaitingResponseTypeSign,
    PFWaitingResponseTypeDetail,
    PFWaitingResponseTypeValidate
};

typedef NS_ENUM (NSInteger, PFSortPickerRow) {
    PFSortPickerRowDate,
    PFSortPickerRowSubject,
    PFSortPickerRowApp
};

static const NSInteger kPFAlertViewCancelButtonIndex = 0;
static const NSInteger kPFInitialYearForFilters = 2010;

static const NSTimeInterval kPFRequestTimeoutInterval = 30.0;

static NSString *const kPFDeviceModeliPhone = @"iPhone";

static NSString *const kPFTrue = @"true";
static NSString *const kPFFalse = @"false";
static NSString *const kPFDefaultDateFormat = @"dd/MM/yyyy";

// User Defaults
static NSString *const kPFUserDefaultsKeyCurrentServer = @"currentServer";
static NSString *const kPFUserDefaultsKeyCurrentCertificate = @"currentCertificate";
static NSString *const kPFUserDefaultsKeyAlias = @"alias";
static NSString *const kPFUserDefaultsKeyURL = @"URL";
static NSString *const kPFUserDefaultsKeyDNI = @"DNI";
static NSString *const kPFUserDefaultsKeyServersArray = @"serversArray";
static NSString *const kPFUserDefaultsKeyRemoteCertificates = @"remoteCertificates";
static NSString *const kPFUserDefaultsKeyRemoteCertificatesSelection = @"remoteCertificatesSelection";
static NSString *const kPFUserDefaultsKeyUserSelectionFilterSubject
 = @"userSelectionFilterSubject";
static NSString *const kPFUserDefaultsKeyUserSelectionFilterApp
 = @"userSelectionFilterApplication";
static NSString *const kPFUserDefaultsKeyUserSelectionFilterType
 = @"userSelectionFilterType";
static NSString *const kPFUserDefaultsKeyUserSelectionFilterTimeInterval
 = @"userSelectionFilterTimeInterval";
static NSString *const kPFUserDefaultsKeyUserSelectionFilterYear
 = @"userSelectionFilterYear";
static NSString *const kPFUserDefaultsKeyUserRoles = @"userRoles";
static NSString *const kPFUserDefaultsKeyUserRoleSelected = @"userRoleSelected";
static NSString *const kPFUserDefaultsKeyUserConfigurationCompatible = @"UserConfigurationCompatible";
static NSString *const kPFUserDefaultsKeyPortafirmasNotificationsActivated = @"PortafirmasNotificationsActivated";
static NSString *const kPFUserDefaultsKeyUserNotificationsActivated = @"UserNotificationsActivated";
static NSString *const kPFUserDefaultsKeyPushNotificationsServiceToken = @"PushNotificationsServiceToken";

//Certificate
static NSString *const kPFCertInfoKeyIssuer = @"issuer";
static NSString *const kPFCertInfoKeySubject = @"subject";
static NSString *const kPFCertInfoKeyStartDate = @"startDate";
static NSString *const kPFCertInfoKeyEndDate = @"endDate";
static NSString *const kPFCertInfoKeyPurpose = @"purpose";

//Roles
static NSString *const kUserRoleUserNameKey = @"userName";
static NSString *const kUserRoleRoleNameKey = @"roleName";
static NSString *const kUserRoleUserDNIKey = @"dni";
static NSString *const kUserRoleRoleNameValidator = @"VALIDADOR";

//Filters
static NSString *const kPFFilterKeyType =  @"tipoFilter";
static NSString *const kPFFilterValueTypeViewAll =  @"view_all";
static NSString *const kPFFilterValueTypeViewNoValidate =  @"view_no_validate";
static NSString *const kFilterKeyMonth =  @"mesFilter";
static NSString *const kFilterKeyYear =  @"anioFilter";
static NSString *const kFilterMonthAll =  @"all";
static NSString *const kFilterDNIKey =  @"dni";
static NSString *const kFilterDNIValidator =  @"dniValidadorFilter";
static NSString *const kPFFilterKeySort = @"orderAscDesc";
static NSString *const kPFFilterValueSortAsc = @"asc";
static NSString *const kPFFilterValueSortDesc = @"desc";
static NSString *const kPFFilterKeySubject = @"searchFilter";
static NSString *const kPFFilterKeySortCriteria = @"orderAttribute";
static NSString *const kPFFilterValueSortCriteriaDate = @"fmodified";
static NSString *const kPFFilterValueSortCriteriaSubject = @"dsubject";
static NSString *const kPFFilterValueSortCriteriaApp = @"application";
static NSString *const kPFFilterKeyApp = @"applicationFilter";

//Notifications
static NSString *const kPortafirmasNotificationsConfigActivated =  @"S";
static NSString *const kUserNotificationsConfigActivated =  @"S";

@interface PFHelper : NSObject

+ (PFRequestType)getPFRequestTypeFromString:(NSString *)string;
+ (PFRequestStatus)getPFRequestStatusFromString:(NSString *)string;
+ (PFRequestStatus)getPFRequestStatusFromClass:(Class)classObject;
+ (PFRequestCode)getPFRequestCodeForSection:(NSInteger)section;
+ (NSString *)getPFSortCriteriaValueForRow:(PFSortPickerRow)row;
+ (NSArray *)getYearsForFilter;
+ (NSString *)getCurrentYear;

@end
