//
//  NSAttributedString+StringStyles.h
//  Spree
//
//  Created by Rush on 11/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (StringStyles)

+(NSAttributedString *) navigationTitleStyle:(NSString *) string;
+(NSAttributedString *) navigationTitleStyle:(NSString *) string color:(UIColor *) color;

+(NSAttributedString *) addSpacing:(NSInteger) spacingAmount string:(NSString *) string;
+(NSAttributedString *) addSpacing:(NSInteger) spacingAmount color:(UIColor *) color string:(NSString *) string;

-(NSAttributedString *) navigationTitleStyle:(NSString *) string;

+(NSAttributedString *) getProductLabelWithNumberOfProducts:(NSInteger) numberOfProducts;

@end
