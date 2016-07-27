//
//  SortByViewController.h
//  Fount
//
//  Created by Rush on 12/7/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@protocol SortByDelegate <NSObject>

//-(void) sortSelectedWithSort:(NSString *) sortString;
-(void) sortSelectedWithSelectedIndex:(NSInteger) selectedIndex;
-(void) sortByDismissed;

@end

@interface SortByViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id <SortByDelegate> delegate;

@end
