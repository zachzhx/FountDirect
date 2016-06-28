//
//  UIColor+CustomColors.h
//  Spree
//
//  Created by Rush on 9/14/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CustomColors)

+(UIColor *) themeColor;
+(UIColor *) lightGrayBackgroundColor;
+(UIColor *) grayFontColor;
+(UIColor *) borderColor;
+(UIColor *) discoverPageButtonBackgroundColor;
+(UIColor *) customLightGrayColor;
+(UIColor *) appBackgroundColor;
+(UIColor *) selectedGrayColor;
+(UIColor *) filterBackgroundColor;
+(UIColor *) searchUnselectedButtonColor;
+(UIColor *) greenMessageColor;

/**
 *  Assumes input like "#00FF00" (#RRGGBB)
 */
+(UIColor *)colorFromHexString:(NSString *)hexString;

@end