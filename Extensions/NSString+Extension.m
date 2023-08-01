    //
    //  NSString+Extension.m
    //  PortaFirmasUniv
    //
    //  Created by Sergio Peñín on 08/01/2020.
    //  Copyright © 2020 Solid Gear Projects S.L. All rights reserved.
    //

#import <Foundation/Foundation.h>
#import "NSString+Extension.h"

@implementation NSString (Common)

- (NSString *) localized {
    return NSLocalizedString(self, nil);
}

    // Function to calculate the maximum width that a text occupies
- (CGSize)usedSizeForMaxWidth:(CGFloat)width withFont:(UIFont *)font
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, MAXFLOAT)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect frame = [layoutManager usedRectForTextContainer:textContainer];
    return CGSizeMake(ceilf(frame.size.width),ceilf(frame.size.height));
}

- (NSString *)replacingWithPattern:(NSString *)pattern withTemplate:(NSString *)withTemplate error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:withTemplate];
}

@end
