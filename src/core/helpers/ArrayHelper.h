//
//  DateHelper.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 14/3/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayHelper : NSObject

+ (NSMutableArray *)getSortedArrayByExpirationDateAndDate: (NSMutableArray *)array;

@end
