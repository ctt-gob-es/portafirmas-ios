//
//  UIFont+Styles.m
//  PortaFirmasUniv
//
//  Created by Sergio PH on 23/09/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "UIFont+Styles.h"

@implementation UIFont (Styles)

+(UIFont *)headerFontStyle {
    return [UIFont fontWithName: @"Helvetica" size: 17.0];
}

+(UIFont *)clearStyleTitleDetailCell {
    return [UIFont fontWithName: @"Helvetica" size: 16.0];
}

+(UIFont *)clearStyleValueDetailCell {
    return [UIFont fontWithName: @"Helvetica" size: 14.0];
}

+(UIFont *)clearStyleTitleRequestCell {
    return [UIFont fontWithName: @"Helvetica" size: 15.0];
}

+(UIFont *)clearStyleValueRequestCell {
    return [UIFont fontWithName: @"Helvetica" size: 12.0];
}

@end
