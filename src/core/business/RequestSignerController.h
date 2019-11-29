//
//  RequestSignerController.h
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana Sánchez on 14/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "WSDataController.h"
#import "CertificateUtils.h"
#import "Detail.h"
#import "Document.h"

@protocol RequestSignerEvent <NSObject>

- (void)didReceiveSignerRequestResult:(NSArray *)requestsSigned;

@optional
- (void)didReceiveError:(NSString *)errorString;
- (void)showErrorInFIReAndRefresh:(NSString *)errorString;
- (void)showFIRMeWebView:(NSURL *) url;
- (void)didReceiveCorrectSignResponseFromFIRe;
- (void)didReceiveErrorSignResponseFromFIRe:(NSInteger)error;

@end

@interface RequestSignerController : NSObject<WSDelegate>
{
    NSArray *preSignRequests;
    NSMutableArray *_dataSource;

    BOOL waitingPreSign;
    BOOL waitingPostSign;

    CertificateUtils *_certificate;
    WSDataController *_wsController;

}
@property (nonatomic, strong) id <RequestSignerEvent> delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property NSInteger pendingRequestIndex;

- (void)loadPreSignRequestsWithCurrentCertificate:(NSArray *)requests;
- (void)loadPreSignDetailWithCurrentCertificate:(Detail *)detail;
- (void)loadPostSignRequest:(NSArray *)requests;
- (void)sendSignRequestForFIRe:(NSArray *)requests;
- (void)signPrechargedRequestInFIRe;

- (void)cancelConnection;
- (void)didReceiveParserWithError:(NSString *)errorString;
- (void)doParse:(NSData *)data;

// Sign list of requests
- (void)signRequestList:(NSArray *)requests;
// Sign selected document
- (void)signDocument:(Document *)reqDoc;

// Testing
- (void)showSignature:(NSString *)dataStr withCertificate:(CertificateUtils *)certificate withMdalgo:(NSString *)mdalgo;

@end
