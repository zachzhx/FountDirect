//
//  ViewAllViewController.h
//  Fount
//
//  Created by Rush on 2/3/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@interface ViewAllViewController : UIViewController

@property (weak, nonatomic) IBOutlet FilterView *filterView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(instancetype) initWithSellerId:(NSInteger) sellerId sellerName:(NSString *) sellerName;
-(instancetype) initWithKeyword:(NSString *) keyword;
@property (nonatomic, assign) BOOL fromShoppingCart;


@end
