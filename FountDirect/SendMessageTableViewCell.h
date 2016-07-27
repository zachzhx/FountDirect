//
//  SendMessageTableViewCell.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/29/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SendMessageViewWidthConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendMessageViewHeightConstraint;

@end
