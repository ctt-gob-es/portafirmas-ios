//
//  AttachedDoc.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 9/1/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachedDoc : NSObject

@property (strong, nonatomic) NSString *docid;
@property (strong, nonatomic) NSString *nm;
@property (strong, nonatomic) NSString *sz;
@property (strong, nonatomic) NSString *mmtp;
@property (strong, nonatomic) NSString *sigfrmt;
@property (strong, nonatomic) NSString *mdalgo;
@property (strong, nonatomic) NSArray *params;

- (void)prepareForRequestWithCode:(PFRequestCode)code;

@end
