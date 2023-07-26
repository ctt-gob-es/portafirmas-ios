//
//  NSString+Extension.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 08/01/2020.
//  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Common)

- (NSString *) localized;
- (CGSize)usedSizeForMaxWidth:(CGFloat)width withFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
