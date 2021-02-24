//
//  ValidateController.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 13/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import "ValidateController.h"
#import "Detail.h"
#import "CertificateUtils.h"
#import "NSData+Base64.h"
#import "PFRequest.h"
#import "PFRequestResult.h"
#import "LoginService.h"

@implementation ValidateController

@synthesize dataSource = _dataSource;

#pragma mark - Init methods

- (ValidateController *)initXMLParser {
    self = [super init];
    _dataSource = nil;
    _dataSource = [[NSMutableArray alloc] init];
    return self;
}

#pragma mark - Request builder

+ (NSString *)buildRequestWithRequestArray:(NSArray *)requestsArray {
    NSMutableString *requestString = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><verfreq>" mutableCopy];
    if (![[LoginService instance] serverSupportLogin]) {
        [requestString appendString:[self certificateTag]];
    }
    [requestString appendString:[self requestsIDTagWithRequests:requestsArray]];
    [requestString appendString:@"</verfreq>"];
    return requestString;
}

+ (NSString *)certificateTag {
    NSString *certificateString = [[[CertificateUtils sharedWrapper] publicKeyBits] base64EncodedString];
    if (certificateString){
        NSMutableString *certificateTag = [@"<cert>" mutableCopy];
        [certificateTag appendFormat:@"%@", certificateString];
        [certificateTag appendString:@"</cert>"];
        return certificateTag;
    } else {
        return @"";
    }
}

+ (NSString *)requestsIDTagWithRequests:(NSArray *)requestsArray {
    NSMutableString *requestsIDtring = [[NSMutableString alloc] initWithString:@""];
    [requestsIDtring appendFormat:@"<reqs>"];
    for (int i = 0; i < [requestsArray count]; i++) {
        if ([requestsArray[i] isKindOfClass:[PFRequest class]]) {
            [requestsIDtring appendFormat:@"<r id=\"%@\"/>", [(PFRequest *)requestsArray[i] reqid]];
        } else if ([requestsArray[i] isKindOfClass:[Detail class]]) {
            [requestsIDtring appendFormat:@"<r id=\"%@\"/>", [(Detail *)requestsArray[i] detailid]];
        }
    }
    [requestsIDtring appendFormat:@"</reqs>"];
    return requestsIDtring;
}

#pragma makr - Parsing methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    if ([elementName isEqualToString:@"r"]) {
        requestResult = [[PFRequestResult alloc] init];
        requestResult.validateId = [attributeDict objectForKey:@"id"];
        requestResult.status = [attributeDict objectForKey:@"ok"];
        [_dataSource addObject:requestResult];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
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
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    //Check this string to be the correct one
    if ([elementName isEqualToString:@"verifrp"]) {
        // We reached the end of the XML document
        return;
    }
    currentElementValue = nil;
}

@end
