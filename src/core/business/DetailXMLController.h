//
//  DetailXMLController.h
//  TopSongs
//
//  Created by Antonio Fiñana on 31/10/12.
//
//

#import <Foundation/Foundation.h>
#import "XMLController.h"


@class Detail;
@class Document;
@class SignLine;
@class Receiver;
@class AttachedDoc;

@interface DetailXMLController : XMLController<NSXMLParserDelegate>{
   
    
    // user object
    Detail *_detail;
        
    // waiting for document
    BOOL waitingForDocument;
    
    // Document object
    Document *document;
    // array of documents objects
    NSMutableArray *documents;
    
    //waiting for attached doc
    BOOL waitingForAttachedDoc;
    // Attached object
    AttachedDoc *attachedDoc;
    // array of attached docs
    NSMutableArray *attachedDocs;

    NSString *type;
    
    // waiting for Signline
    BOOL waitingForSignline;
    
    // Signline object
    SignLine *signline;

    // Receiver object
    Receiver *receiver;

    // array of user objects
    NSMutableArray *signlines;
    
    // waiting for Signline
    BOOL waitingForSenders;
    
    
    // array of user objects
    NSMutableArray *senders;
}

@property (nonatomic, retain) Detail* dataSource;
// Builds Web Service Request message
+(NSString *) buildRequestWithId:(NSString* )rqdtlid;
- (DetailXMLController *) initXMLParser;


@end
