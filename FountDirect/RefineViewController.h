//
//  RefineViewController.h
//  Fount
//
//  Created by Rush on 12/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RefineViewDelegate <NSObject>

//-(void) refineViewSearchProductsWithSellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale;

-(void) refineViewSearchProductsWithSellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale productCount:(NSInteger) productCount;

@end

@interface RefineViewController : UIViewController

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSMutableArray *sellerIds;
@property (nonatomic, strong) NSMutableArray *categoryIds;
@property (nonatomic, strong) NSMutableArray *brandIds;
@property (nonatomic, strong) NSMutableArray *priceRangesArray;
@property (nonatomic, assign) NSInteger minPrice;
@property (nonatomic, assign) NSInteger maxPrice;
@property (nonatomic, assign) NSInteger sale;
@property (nonatomic, strong) NSString *availability;

@property (nonatomic, assign) BOOL isABrand, isASeller;

@property (nonatomic, weak) id <RefineViewDelegate> delegate;

@end
