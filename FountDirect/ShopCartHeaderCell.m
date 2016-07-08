//
//  ShopCartHeaderCell.m
//  Spree
//
//  Created by Xu Zhang on 10/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ShopCartHeaderCell.h"

@implementation ShopCartHeaderCell
@synthesize aline;
@synthesize aSelectBtn;
@synthesize editBtn;
@synthesize aSellerNameLbl;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
