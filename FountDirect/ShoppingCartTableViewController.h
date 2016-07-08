//
//  ShoppingCartTableViewController.h
//  Spree
//
//  Created by Xu Zhang on 10/13/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCartTableViewController : UITableViewController<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL fromNavigate;
@property (nonatomic, assign) BOOL fromViewAll;

@property (nonatomic, strong) UIView *dropdownView;
@property (strong,nonatomic) UILabel *dropdownLabel;

@end
