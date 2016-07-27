//
//  SingleChatTableViewCell.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/28/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView2;
@property (weak, nonatomic) IBOutlet UIView *unreadMessageView;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageLabel;

@end
