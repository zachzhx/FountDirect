//
//  SingleChatTableViewCell.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/28/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "SingleChatTableViewCell.h"

@implementation SingleChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView2.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView2.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
