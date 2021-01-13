//
//  ValidateController.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 13/01/2021.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLController.h"

@interface ValidateController : XMLController <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableArray *dataSource;

+ (NSString *)buildRequestWithRequestArray:(NSArray *)requestsArray;

@end
