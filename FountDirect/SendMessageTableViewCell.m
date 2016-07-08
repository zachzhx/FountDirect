//
//  SendMessageTableViewCell.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/29/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "SendMessageTableViewCell.h"

@implementation SendMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    _messageView.layer.cornerRadius = _messageView.frame.size.height/10;
    _messageView.layer.cornerRadius = 10;
    _messageView.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
