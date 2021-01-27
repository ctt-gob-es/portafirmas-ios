//
//  PreSignXMLController.m
//  WSFirmaClient
//
//  Created by Antonio Fiñana on 05/11/12.
//
//

#import "PreSignXMLController.h"
#import "PFRequest.h"
#import "Document.h"
#import "Param.h"
#import "LoginService.h"

@implementation PreSignXMLController

@synthesize dataSource = _dataSource;

// Builds Web Service Request message
+ (NSString *)buildRequestWithCert:(NSString *)cert witRequestList:(NSArray *)requests;
{
    NSMutableString *mesg = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rqttri>\n"];
    
    if (![[LoginService instance] serverSupportLogin]) {
		if (cert) {
			[mesg appendFormat:@"<cert>%@</cert>\n", cert];
		}
    }

    // Filters list message
    NSMutableString *requestsMsg = [[NSMutableString alloc] initWithString:@"<reqs>"];
    for (int i = 0; i < [requests count]; i++) {
        PFRequest *request = [requests objectAtIndex:i];
        [requestsMsg appendFormat:@"<req id=\"%@\" >", [request reqid]];

        NSArray *documents = request.documents;

        if ((documents) && ([documents count] > 0)) {
            for (int j = 0; j < [documents count]; j++) {
                Document *document = [documents objectAtIndex:j];

                if (document.mdalgo) {
                    [requestsMsg appendFormat:@"\t<doc docid=\"%@\" cop=\"%@\" sigfrmt=\"%@\" mdalgo=\"%@\">\n", document.docid, document.cop, document.sigfrmt, document.mdalgo];
                }
                else {
                    [requestsMsg appendFormat:@"\t<doc docid=\"%@\" cop=\"%@\" sigfrmt=\"%@\">\n", document.docid, document.cop, document.sigfrmt];
                }

                if (document.params) {
                    [requestsMsg appendFormat:@"\t\t<params>%@</params>\n", document.params];
                } else {
                    [requestsMsg appendFormat:@"\t\t<params></params>\n"];
                }
                [requestsMsg appendFormat:@"</doc>"];
            }
        }
        // end request
        [requestsMsg appendString:@"</req>\n"];
    }     // end for

    // end message
    [requestsMsg appendString:@"</reqs></rqttri>\n"];
    [mesg appendString:requestsMsg];

    return mesg;
}

+ (NSData *)buildRequestWithoutCertWithRequestList:(NSArray *)requests{
	NSMutableString *mesg = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rqttri>\n"];
	NSMutableString *requestsMsg = [[NSMutableString alloc] initWithString:@"<reqs>"];
	for (int i = 0; i < [requests count]; i++) {
		PFRequest *request = [requests objectAtIndex:i];
		[requestsMsg appendFormat:@"<req id=\"%@\"/>", [request reqid]];
	}
    [requestsMsg appendString:@"</reqs></rqttri>\n"];
    [mesg appendString:requestsMsg];
	NSData *mesgData = [mesg dataUsingEncoding:NSUTF8StringEncoding];
	return mesgData;
}

+ (NSData *)buildRequestWithoutCertWithRequest:(Detail *)request {
	NSMutableString *mesg = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rqttri>\n"];
	NSMutableString *requestsMsg = [[NSMutableString alloc] initWithString:@"<reqs>"];
	[requestsMsg appendFormat:@"<req id=\"%@\"/>", [request detailid]];
    [requestsMsg appendString:@"</reqs></rqttri>\n"];
    [mesg appendString:requestsMsg];
	NSData *mesgData = [mesg dataUsingEncoding:NSUTF8StringEncoding];
	return mesgData;
}

+ (NSData *)buildDataForSigningPrechargedRequestInFIRe {
	NSMutableString *mesg = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<cfrq />\n"];
	NSData *mesgData = [mesg dataUsingEncoding:NSUTF8StringEncoding];
	return mesgData;
}

- (PreSignXMLController *)initXMLParser
{
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

// Parse the start of an element
- (void)     parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qualifiedName
         attributes:(NSDictionary *)attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

    if ([elementName isEqualToString:@"req"]) {
        request = [[PFRequest alloc] init];
        documentList = [[NSMutableArray alloc] init];

        // if We attributes in the user elements, you can extract them here:
        request.reqid = [attributeDict objectForKey:@"id"];
        request.status = [attributeDict objectForKey:@"status"];
    }

    if ([elementName isEqualToString:@"doc"]) {
        // We reached the end of the XML document
        waitingForDocument = YES;
        document = [[Document alloc]init];
        document.docid = [attributeDict objectForKey:@"docid"];
        document.cop = [attributeDict objectForKey:@"cop"];
        document.sigfrmt = [attributeDict objectForKey:@"sigfrmt"];
        document.mdalgo = [attributeDict objectForKey:@"mdalgo"];
        document.ssconfig = [[NSMutableArray alloc] init];
    }

    if ([elementName isEqualToString:@"p"]) {
        // addresses is an NSMutableArray instance variable
        NSString *atributosP = [attributeDict objectForKey:@"n"];

        if (atributosP) {
            ssparam = [[Param alloc]init];
            ssparam.key = atributosP;
        }

        return;
    }
}

// Parse an element value
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *strNew = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    strNew = [strNew stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    strNew = [strNew stringByReplacingOccurrencesOfString:@"&_lt;" withString:@"<"];
    strNew = [strNew stringByReplacingOccurrencesOfString:@"&_gt;" withString:@">"];

    if ([strNew isEqualToString:@"\n"]) {
        return;
    }

    if (!currentElementValue) {
        // init the ad hoc string with the value initWithData:xmlData encoding:NSUTF8StringEncoding
        currentElementValue = [[NSMutableString alloc] initWithString:strNew];
    } else {
        // append value to the ad hoc string
        [currentElementValue appendString:strNew];
    }
}

// XMLParser.m
- (void)   parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

    if ([elementName isEqualToString:@"pres"]) {

        // We reached the end of the XML document
        return;
    } else if ([elementName isEqualToString:@"doc"]) {
        // We reached the end of the XML document
        waitingForDocument = NO;
        [documentList addObject:document];
        document = nil;

        return;
    }
    else if ([elementName isEqualToString:@"p"]) {

        // We reached the end of the document's param node
        ssparam.value = currentElementValue;
        currentElementValue = nil;
        [document.ssconfig addObject: ssparam];
        ssparam = nil;
        
        return;
    }
    else if ([elementName isEqualToString:@"req"]) {
        // We reached the end of the XML document
        request.documents = documentList;
        documentList = nil;

        [_dataSource addObject:request];
        request = nil;

        return;
    }
    // The parser hit one of the element values.
    // This syntax is possible because User object
    // property names match the XML user element names
    if (waitingForDocument) {
        [document setValue:currentElementValue forKey:elementName];
    }
    else {
        [request setValue:currentElementValue forKey:elementName];
    }
    currentElementValue = nil;
    
}

@end
