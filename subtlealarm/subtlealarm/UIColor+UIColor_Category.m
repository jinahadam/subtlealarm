//
//  UIColor+UIColor_Category.m
//  subtlealarm
//
//  Created by Jinah Adam on 17/3/18.
//  Copyright © 2018 Jinah Adam. All rights reserved.
//

#import "UIColor+UIColor_Category.h"

@implementation UIColor (UIColor_Category)

+ (UIColor *) neutralColor {
    UIColor *color  = [UIColor colorWithRed:0.993 green:0.535 blue:0.000 alpha:1.00];
    return color;
}

+ (UIColor *) alarmColor {
    UIColor *color  = [UIColor colorWithRed:0.987 green:0.256 blue:0.009 alpha:1.00];
    return color;
}

@end
