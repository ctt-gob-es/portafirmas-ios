//
//  AppListXMLController.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 13/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "AppListXMLController.h"
#import "CertificateUtils.h"
#import "NSData+Base64.h"
#import "LoginService.h"

@interface AppListXMLController ()
{
    NSMutableArray *_appsArray;
    WSDataController *_wsDataController;
}

@end

@implementation AppListXMLController

static AppListXMLController *_sharedInstance = nil;

+ (AppListXMLController *)sharedInstance
{
    @synchronized([AppListXMLController class])
    {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }

        return _sharedInstance;
    }

    return nil;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        _wsDataController = [[WSDataController alloc] init];
        [_wsDataController setDelegate:self];
    }

    return self;
}

- (void)requestAppsList
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
    NSString *requestString = [self buildRequest];
    [_wsDataController loadPostRequestWithData:requestString code:PFRequestCodeAppList];
    [_wsDataController startConnection];
   
}

- (NSArray *)appsArray
{
    return _appsArray;
}

#pragma mark - Request builder

- (NSString *)buildRequest
{
    NSMutableString *requestString = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rqtconf>\n" mutableCopy];

    if (![[LoginService instance] serverSupportLogin]) {
        [requestString appendString:[self certificateTag]];
    }
    [requestString appendString:@"</rqtconf>"];

    return requestString;
}

- (NSString *)certificateTag
{
    NSString *certificateString = [NSData base64EncodeData:[[CertificateUtils sharedWrapper] publicKeyBits]];
	if (certificateString){
		NSMutableString *certificateTag = [@"<cert>\n" mutableCopy];
		[certificateTag appendFormat:@"%@\n", certificateString];
		[certificateTag appendString:@"</cert>\n"];
		return certificateTag;
	} else {
		return @"";
	}
}

#pragma mark - WSDelegate

- (void)doParse:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    [nsXmlParser setDelegate:self];
    BOOL success = [nsXmlParser parse];

    if (success) {
        BOOL finishOK = ![self finishWithError];

        if (!finishOK) {
            _appsArray = nil;
        }
    } else {
        _appsArray = nil;
    }
}

- (void)didReceiveParserWithError:(NSString *)errorString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    _appsArray = nil;
}

#pragma makr - Parsing methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

    if ([elementName isEqualToString:@"appConf"]) {
        _appsArray = [@[] mutableCopy];
    }

    if ([elementName isEqualToString:@"app"]) {
        [_appsArray addObject:attributeDict[@"id"]];
    }
}

@end
