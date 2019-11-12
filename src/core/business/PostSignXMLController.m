//
//  PostSignXMLController.m
//  WSFirmaClient
//
//  Created by Antonio Fiñana on 05/11/12.
//
//

#import "PostSignXMLController.h"
#import "PFRequest.h"
#import "Document.h"
#import "Param.h"
#import "Base64Utils.h"
#import "LoginService.h"

@implementation PostSignXMLController

@synthesize dataSource = _dataSource;

// Builds Web Service Request message
+ (NSString *)buildRequestWithCert:(NSString *)cert witRequestList:(NSArray *)requests;
{
    NSMutableString *mesg = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rqttri>\n"];
   
    if (![[LoginService instance] serverSupportLogin]) {
        [mesg appendFormat:@"<cert>%@</cert>\n", cert];
    }

    // Filters list message
    NSMutableString *requestsMsg = [[NSMutableString alloc] initWithString:@"<reqs>"];
    for (int i = 0; i < [requests count]; i++) {
        PFRequest *request = [requests objectAtIndex:i];

        if ([request status]) {
            [requestsMsg appendFormat:@"\t<req id=\"%@\"  status=\"%@\" >", [request reqid], [request status]];
        }
        else {
            [requestsMsg appendFormat:@"\t<req id=\"%@\"  status=\"%@\" >", [request reqid], @"OK"];
        }

        NSArray *documents = request.documents;

        if (documents) {
            for (int j = 0; j < [documents count]; j++) {
                Document *document = [documents objectAtIndex: j];

                if (document.mdalgo) {
                    [requestsMsg appendFormat:@"\t<doc docid=\"%@\" cop=\"%@\" sigfrmt=\"%@\" mdalgo=\"%@\">\n", document.docid, document.cop, document.sigfrmt, document.mdalgo];
                    
                }
                else {
                    [requestsMsg appendFormat:@"\t<doc docid=\"%@\" cop=\"%@\" sigfrmt=\"%@\">\n", document.docid, document.cop, document.sigfrmt];
                }

                if (document.params) {
                    [requestsMsg appendFormat:@"\t\t<params>%@</params>\n", document.params];
                }
                else {
                    [requestsMsg appendFormat:@"\t\t<params></params>\n"];
                }

                NSMutableString *result = [[NSMutableString alloc] initWithString:@"\t\t<result>"];
                for (int z = 0; z < [document.ssconfig count]; z++) {
                    Param *param = [document.ssconfig objectAtIndex: z];
                    [result appendFormat:@"<p n='%@'>%@</p>", param.key, param.value];
                }
                
                [requestsMsg appendFormat:@"%@", result];
                [requestsMsg appendFormat:@"<p n='PK1'>%@</p>", document.result];
                
                [requestsMsg appendFormat:@"</result>\n"];

                [requestsMsg appendString:@"\t</doc>\n"];
            }
        }
        [requestsMsg appendString:@"\t</req>\n"];
    }
    [requestsMsg appendString:@"</reqs></rqttri>\n"];
    
    [mesg appendString:requestsMsg];
    return mesg;
}

- (PostSignXMLController *)initXMLParser
{
    self = [super init];

    if (self) {
        // init array of user objects
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
        /*
           request.documents=[[NSMutableArray alloc] init];
           waitingForDocument=FALSE;
         */

        // if We attributes in the user elements, you can extract them here:
        request.reqid = [attributeDict objectForKey:@"id"];
        request.status = [attributeDict objectForKey:@"status"];

        /*
           if (!documentList) {
            documentList=[[NSMutableArray alloc ]init];
           }
         */
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

// Parse the end of an element
- (void)   parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

    if ([elementName isEqualToString:@"posts"]) {

        // We reached the end of the XML document
        return;
    }

    if ([elementName isEqualToString:@"req"]) {
        // We reached the end of the XML document
        [_dataSource addObject:request];
        // [request release];
        request = nil;

        return;
    }
    // [currentElementValue release];
    currentElementValue = nil;
}

@end
