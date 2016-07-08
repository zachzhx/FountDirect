//
//  ShopMainCell.m
//  Spree
//
//  Created by Xu Zhang on 10/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ShopMainCell.h"

@implementation ShopMainCell
@synthesize aSelectBtn;
@synthesize aThumbImg;
@synthesize brandNameLbl,aColorLbl,aSizeLbl,aPriceLbl,aQuantityLbl,aShopLbl;
@synthesize aFitLbl,aInseamLbl;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
