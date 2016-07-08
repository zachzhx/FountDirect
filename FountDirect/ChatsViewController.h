//
//  ChatsViewController.h
//  FountDirect
//
//  Created by Zhang Xu on 6/27/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
