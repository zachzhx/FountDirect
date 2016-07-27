//
//  SortByTableViewCell.m
//  Fount
//
//  Created by Rush on 12/7/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "SortByTableViewCell.h"
#import "UIColor+CustomColors.h"

@implementation SortByTableViewCell

- (void)awakeFromNib {
    
    //Remove left inset from tableView
    [self setLayoutMargins:UIEdgeInsetsZero];
    
    self.mainLabel.textColor = [UIColor grayFontColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.mainLabel.textColor = [UIColor themeColor];
        self.mainImageView.hidden = NO;
    } else {
        self.mainLabel.textColor = [UIColor grayFontColor];
        self.mainImageView.hidden = YES;
    }
}

@end
