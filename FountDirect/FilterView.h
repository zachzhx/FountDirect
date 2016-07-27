//
//  FilterView.h
//  Spree
//
//  Created by Rush on 10/21/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewDelegate <NSObject>

-(void) filterSortByClicked:(UIViewController *) viewController;
-(void) filterSortByString:(NSString *) sortByString;
-(void) filterRefineClicked:(UIViewController *) viewController;

@end

@interface FilterView : UIView

@property (nonatomic, weak) IBOutlet UIView *view;
//@property (strong, nonatomic) UILabel *numberOfProductsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfProductsLabel;
@property (weak, nonatomic) IBOutlet UIButton *refineButton;
@property (weak, nonatomic) IBOutlet UIImageView *refineArrowImageView;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) NSInteger numberOfProducts;
@property (nonatomic, weak) id <FilterViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *sortByButton;
@property (weak, nonatomic) IBOutlet UIImageView *sortByArrowImageView;


@end
