//
//  UINavigationBar+DropShadow.m
//  Spree
//
//  Created by Rush on 9/22/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "UINavigationBar+DropShadow.h"

@implementation UINavigationBar (DropShadow)

-(void) enableDropShadow {
    //Remove border under nav
    for (UIView *view in self.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UIImageView class]]) {
                [view2 removeFromSuperview];
            }
        }
    }
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0.0);
    self.layer.shadowRadius = 1.0f;
    
    CGRect shadowPath = CGRectMake(-2, self.frame.size.height, self.frame.size.width + 4, 0.5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
}

@end
