//
//  AproveXMLController.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 6/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "ApproveXMLController.h"
#import "Detail.h"
#import "CertificateUtils.h"
#import "NSData+Base64.h"
#import "PFRequest.h"
#import "PFRequestResult.h"
#import "LoginService.h"

@interface ApproveXMLController ()
{
    PFRequestResult *_requestResult;
}

@end

@implementation ApproveXMLController

#pragma mark - Init methods

- (instancetype)init
{
    self = [super init];

    if (self) {
        _dataSource = nil;
    }

    return self;
}

#pragma mark - Request builder

+ (NSString *)buildRequestWithRequestArray:(NSArray *)requestsArray
{
    NSMutableString *requestString = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<apprv>\n" mutableCopy];

    if (![[LoginService instance] serverSupportLogin]) {
        [requestString appendString:[self certificateTag]];
    }
    
    [requestString appendString:[self requestsIDTagWithRequests:requestsArray]];
    [requestString appendString:@"</apprv>"];

    return requestString;
}

+ (NSString *)certificateTag
{
    NSString *certificateString = [[[CertificateUtils sharedWrapper] publicKeyBits] base64EncodedString];
	if (certificateString){
		NSMutableString *certificateTag = [@"<cert>\n" mutableCopy];
		[certificateTag appendFormat:@"%@\n", certificateString];
		[certificateTag appendString:@"</cert>\n"];
		return certificateTag;
	} else {
		return @"";
	}
}

+ (NSString *)requestsIDTagWithRequests:(NSArray *)requestsArray
{
    NSMutableString *requestsIDtring = [[NSMutableString alloc] initWithString:@""];

    [requestsIDtring appendFormat:@"<reqs>\n"];
    for (int i = 0; i < [requestsArray count]; i++) {
        if ([requestsArray[i] isKindOfClass:[PFRequest class]]) {
            [requestsIDtring appendFormat:@"<r id=\"%@\"/>\n", [(PFRequest *)requestsArray[i] reqid]];
        } else if ([requestsArray[i] isKindOfClass:[Detail class]]) {
            [requestsIDtring appendFormat:@"<r id=\"%@\"/>\n", [(Detail *)requestsArray[i] detailid]];
        }
    }
    [requestsIDtring appendFormat:@"</reqs>\n"];

    return requestsIDtring;
}

#pragma makr - Parsing methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

    if ([elementName isEqualToString:@"apprv"]) {

        _requestResult = [PFRequestResult new];
        [_requestResult setRejectId:attributeDict[@"id"]];
        [_requestResult setStatus:attributeDict[@"status"]];
    }

    if ([elementName isEqualToString:@"apprvs"]) {
        _dataSource = [@[] mutableCopy];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *strNew = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    strNew = [strNew stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    strNew = [strNew stringByReplacingOccurrencesOfString:@"&_lt;" withString:@"<"];
    strNew = [strNew stringByReplacingOccurrencesOfString:@"&_gt;" withString:@">"];

    if ([strNew isEqualToString:@"\n"]) {
        return;
    }

    if (currentElementValue) {
        [currentElementValue appendString:strNew];
    } else {
        currentElementValue = [strNew mutableCopy];
    }
}

// XMLParser.m
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

    if ([elementName isEqualToString:@"apprv"]) {
        // We reached the end of the XML document
        [_dataSource addObject:_requestResult];
    }

    currentElementValue = nil;
}

@end
