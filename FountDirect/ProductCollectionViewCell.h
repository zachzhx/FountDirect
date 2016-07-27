//
//  ProductCollectionViewCell.h
//  Spree
//
//  Created by Rush on 10/5/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@protocol ProductCellDelegate <NSObject>

-(void) deleteProduct:(NSUInteger) indexRow;

@end

@interface ProductCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *lineLable;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (nonatomic, strong) Product *product;
//Set to yes in tag controller to show checkmark
@property (nonatomic, assign) BOOL showCheck;
//Set to yes on the MDP to show delete button
@property (nonatomic, assign) BOOL showDeleteButton;
@property (nonatomic, weak) id<ProductCellDelegate> delegate;

-(void) setupCell;
-(void) setupInStockCell;
-(void) setupOutOfStockCellWithPrice:(CGFloat) price;

@end
