//
//  RequestSignerController.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana Sánchez on 14/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "RequestSignerController.h"
#import "WSDataController.h"
#import "AppDelegate.h"
#import "PreSignXMLController.h"
#import "PostSignXMLController.h"
#import "CertificateUtils.h"
#import "NSData+Base64.h"
#import "Detail.h"
#import "PFRequest.h"
#import "Document.h"
#import "Param.h"
#import "Base64Utils.h"
#import "PFError.h"
#import "GlobalConstants.h"

@implementation RequestSignerController

- (id)init
{
    self = [super init];

    if (self) {
        // Sets data in RequestSignerController objet
        // BORRAR :true
        _wsController = [[WSDataController alloc] init:true];
        _wsController.delegate = self;
        waitingPreSign = NO;
        waitingPostSign = NO;
        _pendingRequestIndex = 0;
    }

    return self;
}

- (void)loadPreSignRequestsWithCurrentCertificate:(NSArray *)requests
{
    _pendingRequestIndex = 0;
    _pendingRequests = [[NSMutableArray alloc] initWithArray: requests];
    _dataSource = [[NSMutableArray alloc] init];
    [self sendNextRequest];
}

- (void)sendNextRequest {
    if (_pendingRequestIndex < [_pendingRequests count]) {
        NSArray *nextRequest = [[NSArray alloc] initWithObjects:_pendingRequests[_pendingRequestIndex], nil];
        waitingPreSign = TRUE;
        
        NSData *certificateData = [[CertificateUtils sharedWrapper] publicKeyBits];
        NSString *certificateB64 = [Base64Utils base64EncodeData:certificateData];
        NSString *data = [PreSignXMLController buildRequestWithCert:certificateB64 witRequestList: nextRequest];
        _wsController.delegate = self;
        [_wsController loadPostRequestWithData:data code:0];
        [_wsController startConnection];
        _pendingRequestIndex++;
    } else {
        [[self delegate] didReceiveSignerRequestResult:_dataSource];
    }
}

- (void) sendSignRequestForFIRe:(NSArray *)requests {
	NSInteger code = 16;
	_dataSource = [[NSMutableArray alloc] init];
	NSData *data = [PreSignXMLController buildRequestWithoutCertWithRequestList:requests];
	_wsController.delegate = self;
	[_wsController postSignRequestWithFIRe:data code:code success:^(NSDictionary *content) {
		NSDictionary *responseDict = [content objectForKey:kCfrqtTag];
		NSString *cfrqtValue = [responseDict objectForKey:kOk];
		if ([cfrqtValue isEqualToString:kTrue]) {
			[[self delegate] showFIRMeWebView:[[NSURL alloc] initWithString:[responseDict objectForKey:kContentKey]]];
		} else {
			[[self delegate] showErrorInFIReAndDeselectRows:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
		}
	} failure:^(NSError *error) {
		[[self delegate] showErrorInFIReAndDeselectRows:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
	}];
	[_wsController startConnection];
}

- (void) sendSignRequestForFIReFromDetailView:(Detail *)request {
	NSInteger code = 16;
	NSData *data = [PreSignXMLController buildRequestWithoutCertWithRequest:request];
	_wsController.delegate = self;
	[_wsController postSignRequestWithFIRe:data code:code success:^(NSDictionary *content) {
		NSDictionary *responseDict = [content objectForKey:kCfrqtTag];
		NSString *cfrqtValue = [responseDict objectForKey:kOk];
		if ([cfrqtValue isEqualToString:kTrue]) {
			[[self delegate] showFIRMeWebView:[[NSURL alloc] initWithString:[responseDict objectForKey:kContentKey]]];
		} else {
			[[self delegate] didReceiveError:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
		}
	} failure:^(NSError *error) {
		[[self delegate] didReceiveError:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
	}];
	[_wsController startConnection];
}

-(void) signPrechargedRequestInFIRe {
	NSInteger code = 17;
	NSData *data = [PreSignXMLController buildDataForSigningPrechargedRequestInFIRe];
	_wsController.delegate = self;
	[_wsController postSignRequestWithFIRe:data code:code success:^(NSDictionary *content) {
		NSDictionary *responseDict = [content objectForKey:kCfsigTag];
		if ([[responseDict objectForKey:kOk] isEqualToString:kTrue]) {
			[[self delegate] didReceiveCorrectSignResponseFromFIRe];
		} else if ([[responseDict objectForKey:kOk] isEqualToString:kFalse]) {
			[[self delegate] didReceiveErrorSignResponseFromFIRe:[responseDict objectForKey: kErrorFIReKey]];
		} else {
			[[self delegate] didReceiveErrorInPrechargedFIReRequest:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
		}
	} failure:^(NSError *error) {
		[[self delegate] didReceiveErrorInPrechargedFIReRequest:NSLocalizedString(@"FIRe_error_in_server_message", nil)];
	}];
	[_wsController startConnection];
}

- (void)loadPreSignDetailWithCurrentCertificate:(Detail *)detail
{
    PFRequest *request = [[PFRequest alloc] init];
    request.reqid = detail.detailid;
    request.documents = [detail.documents mutableCopy];
    [self loadPreSignRequestsWithCurrentCertificate: @[request]];
}

- (void)loadPostSignRequest:(NSArray *)requests
{
    // load Pre Sign Request
    [self signRequestList: requests];

    NSData *certificateData = [CertificateUtils sharedWrapper].publicKeyBits;
    // dataFromBase64String
    // NSString *certificateB64 = [certificateData base64EncodedString];
    NSString *certificateB64 = [Base64Utils base64EncodeData:certificateData];
    NSString *data = [PostSignXMLController buildRequestWithCert:certificateB64 witRequestList:requests];
    waitingPostSign = YES;

    [_wsController loadPostRequestWithData:data code:1];
    [_wsController startConnection];
}

- (void)cancelConnection
{
    [_wsController cancelConnection];
    waitingPostSign = waitingPreSign = NO;
}

- (void)didReceiveParserWithError:(NSString *)errorString
{
    if (waitingPreSign) {
        waitingPreSign = NO;
    }

    if (waitingPostSign) {
        waitingPostSign = NO;
    }

    [[self delegate] didReceiveError:errorString];
}

- (void)doParse:(NSData *)data
{
    if (waitingPreSign) {
        waitingPreSign = NO;
        // create and init NSXMLParser object
        NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];

        // create and init our delegate
        PreSignXMLController *parser = [[PreSignXMLController alloc] initXMLParser];

        // set delegate
        [nsXmlParser setDelegate:parser];

        // parsing...
        BOOL success = [nsXmlParser parse];

        // test the result
        if (success) {
            // parsing...

            BOOL finishWithError = [parser finishWithError];

            if (finishWithError) {
                [[self delegate] didReceiveError:[NSString stringWithFormat:NSLocalizedString(@"Global_error_server_error_and_error_code", nil), [parser err], [parser errorCode]]];
                return;
            }

            // get array of users here
            preSignRequests = [parser dataSource];

            [self loadPostSignRequest:preSignRequests];
        } else {
            [[self delegate] didReceiveError:NSLocalizedString(@"Global_Error_Server_Connection", nil)];
        }
    } else if (waitingPostSign) {
        waitingPostSign = NO;
        // create and init NSXMLParser object
        NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];

        // create and init our delegate
        PostSignXMLController *parser = [[PostSignXMLController alloc] initXMLParser];

        // set delegate
        [nsXmlParser setDelegate:parser];

        // parsing...
        BOOL success = [nsXmlParser parse];

        // test the result
        if (success) {
            // get array of users here
            [_dataSource addObjectsFromArray: [parser dataSource]];
            [self sendNextRequest];
        } else {
            [[self delegate] didReceiveError:NSLocalizedString(@"Global_Error_Server_Connection", nil)];
        }
    }
}

// Sign list of requests
- (void)signRequestList:(NSArray *)requests
{
    for (int i = 0; i < [requests count]; i++) {
        PFRequest *_selRequest = [requests objectAtIndex: i];
        NSArray *documents = _selRequest.documents;
        for (int j = 0; j < [documents count]; j++) {
            [self signDocument:[documents objectAtIndex: j]];
        }
    }
}

// Sign selected document
- (void)signDocument:(Document *)reqDoc
{
    NSString *mdalgo = [reqDoc mdalgo];

    if (mdalgo == nil) {
        mdalgo = @"sha1";
    } else {
        mdalgo = [mdalgo lowercaseString];
    }

    NSString *preSignResult = nil;
    for (int i = 0; i < [reqDoc.ssconfig count]; i++) {
        
        Param *param = [reqDoc.ssconfig objectAtIndex: i];
        if ([param.key hasPrefix:@"PRE"]) {
            preSignResult = param.value;
            break;
        }
    }

    if (!preSignResult || preSignResult.length <= 0) {
        return;
    }
    
    NSData *data = [Base64Utils base64DecodeString:preSignResult];
    NSData *result = nil;
    if ([mdalgo isEqualToString:@"sha-1"] || [mdalgo isEqualToString:@"sha1"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA1:data];
    } else if ([mdalgo isEqualToString:@"sha-256"] || [mdalgo isEqualToString:@"sha256"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA256:data];
    } else if ([mdalgo isEqualToString:@"sha-384"] || [mdalgo isEqualToString:@"sha384"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA384:data];
    } else if ([mdalgo isEqualToString:@"sha-512"] || [mdalgo isEqualToString:@"sha512"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA512:data];
    }
    // reqDoc.result=[result base64EncodedString];
    reqDoc.result = [Base64Utils base64EncodeData: result];
}

- (void)showSignature:(NSString *)dataStr withCertificate:(CertificateUtils *)certificate withMdalgo:(NSString *)mdalgo
{
    //  NSData *contentData = [NSData dataFromBase64String:_dataSource.data];
    NSData *data = [dataStr
                    dataUsingEncoding:NSUTF8StringEncoding];

    NSData *result = nil;

    if (mdalgo == nil) {
        mdalgo = @"sha1";
    } else {
        mdalgo = [mdalgo lowercaseString];
    }

    if ([mdalgo isEqualToString:@"sha-1"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA1:data];
    } else if ([mdalgo isEqualToString:@"sha-256"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA256:data];
    } else if ([mdalgo isEqualToString:@"sha-384"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA384:data];
    } else if ([mdalgo isEqualToString:@"sha-512"]) {
        result = [[CertificateUtils sharedWrapper] getSignatureBytesSHA512:data];
    }
}

@end
