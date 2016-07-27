//
//  ConversationViewController.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/29/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, strong) NSMutableArray *profileImagesArray;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) NSInteger chatReferenceId;

@end
