//
//  Reject.h
//  WSFirmaClient
//
//  Created by Antonio Fiñana on 05/11/12.
//
//

#import <Foundation/Foundation.h>

@interface PFRequestResult : NSObject
@property (strong, nonatomic) NSString *rejectId;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *validateId;

// error message
@property (strong, nonatomic) NSString *errorMsg;
@property (nonatomic) NSInteger errorCode;

@end
