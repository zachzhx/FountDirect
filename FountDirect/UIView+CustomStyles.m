//
//  UIView+CustomStyles.m
//  Spree
//
//  Created by Rush on 11/11/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "UIView+CustomStyles.h"

@implementation UIView (CustomStyles)

+(void) addRoundedCornerToView:(UIView *) viewToRound {
    viewToRound.layer.masksToBounds = YES;
    viewToRound.layer.cornerRadius = 5.0;
}

@end
