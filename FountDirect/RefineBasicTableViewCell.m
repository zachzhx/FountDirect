//
//  RefineBasicTableViewCell.m
//  Fount
//
//  Created by Rush on 12/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "RefineBasicTableViewCell.h"
#import "UIColor+CustomColors.h"

@implementation RefineBasicTableViewCell

- (void)awakeFromNib {
    
    self.checkMarkImageView.image = [UIImage imageNamed:@"checkmark"];
    self.checkMarkImageView.hidden = YES;
    
    self.nameLabel.textColor = [UIColor grayFontColor];
    self.productCountLabel.textColor = [UIColor grayFontColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

//    if (selected) {
//        self.checkMarkImageView.hidden = NO;
//    } else {
//        self.checkMarkImageView.hidden = YES;
//    }
}

@end
