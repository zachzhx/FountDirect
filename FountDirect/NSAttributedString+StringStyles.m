//
//  NSAttributedString+StringStyles.m
//  Spree
//
//  Created by Rush on 11/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "NSAttributedString+StringStyles.h"
#import "UIColor+CustomColors.h"

@implementation NSAttributedString (StringStyles)

+(UILabel *) navigationTitleLabel:(NSString *) string {
    UILabel *titleLabel = [UILabel new];
    
    titleLabel.attributedText = [self navigationTitleStyle:string];
    [titleLabel sizeToFit];
    
    return titleLabel;
}

-(NSAttributedString *) navigationTitleStyle:(NSString *) string {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    
    [mutableAttributedString addAttribute:NSKernAttributeName value:@(spacing) range:range];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor themeColor] range:range];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SFUIText-Regular" size:18.0f] range:range];
    
    return mutableAttributedString;
}

+(NSAttributedString *) navigationTitleStyle:(NSString *) string {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    
    [mutableAttributedString addAttribute:NSKernAttributeName value:@(spacing) range:range];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor themeColor] range:range];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SFUIText-Semibold" size:18.0f] range:range];
    
    return mutableAttributedString;
}

+(NSAttributedString *) navigationTitleStyle:(NSString *) string color:(UIColor *) color {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    
    [mutableAttributedString addAttribute:NSKernAttributeName value:@(spacing) range:range];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SFUIText-Regular" size:18.0f] range:range];
    
    return mutableAttributedString;
}

+(NSAttributedString *) addSpacing:(NSInteger) spacingAmount string:(NSString *) string {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    [mutableAttributedString addAttribute:NSKernAttributeName value:@(spacingAmount) range:range];
    
    return mutableAttributedString;
}

+(NSAttributedString *) addSpacing:(NSInteger) spacingAmount color:(UIColor *) color string:(NSString *) string {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    [mutableAttributedString addAttribute:NSKernAttributeName value:@(spacingAmount) range:range];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    return mutableAttributedString;
}

+(NSAttributedString *) getProductLabelWithNumberOfProducts:(NSInteger) numberOfProducts {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *numberAsString = [formatter stringFromNumber:[NSNumber numberWithInteger:numberOfProducts]];
    
    NSDictionary *dictBoldText = @{
                                   NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Semibold" size:12]
                                   };
    
    NSMutableAttributedString *mutAttrTextViewString = [[NSMutableAttributedString alloc] initWithString:numberAsString];
    
    [mutAttrTextViewString setAttributes:dictBoldText range:NSMakeRange(0, mutAttrTextViewString.length)];
    
    NSDictionary *prefixDict = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Regular" size:12]
                                 };
    
    NSAttributedString *stringPrefix = [[NSAttributedString alloc] initWithString:@" Products" attributes:prefixDict];
    
    [mutAttrTextViewString appendAttributedString:stringPrefix];
    
    return mutAttrTextViewString;
}

@end
