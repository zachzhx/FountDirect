//
//  PostImageCollectionViewCell.m
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "PostImageCollectionViewCell.h"
#import "UIColor+CustomColors.h"

@implementation PostImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bigView.layer.borderColor = [UIColor selectedGrayColor].CGColor;
    self.bigView.layer.borderWidth = 1;
    self.bigView.layer.cornerRadius = 5;
    self.bigView.layer.masksToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
}

@end
