//
//  ValidateController.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 13/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLController.h"
#import "PFRequestResult.h"

@interface ValidateController : XMLController <NSXMLParserDelegate> {
    PFRequestResult *requestResult;
    NSMutableArray *_dataSource;
}
@property (nonatomic, retain) NSMutableArray *dataSource;

- (ValidateController *)initXMLParser;
+ (NSString *)buildRequestWithRequestArray:(NSArray *)requestsArray;

@end
