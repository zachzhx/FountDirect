//
//  likesPeopleTableCell.h
//  Fount
//
//  Created by Zhang Xu on 12/22/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface likesPeopleTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *likedUserName;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet UILabel *detailUserLabel;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@end
