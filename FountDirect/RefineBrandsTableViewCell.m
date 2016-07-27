//
//  RefineBrandsTableViewCell.m
//  Fount
//
//  Created by Rush on 12/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "RefineBrandsTableViewCell.h"
#import "UIColor+CustomColors.h"

@implementation RefineBrandsTableViewCell

- (void)awakeFromNib {
    self.checkMarkImageView.image = [UIImage imageNamed:@"checkmark"];
    self.checkMarkImageView.hidden = YES;
    
    self.nameLabel.textColor = [UIColor grayFontColor];
    self.productCountLabel.textColor = [UIColor lightGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
