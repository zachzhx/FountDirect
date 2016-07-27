//
//  ProductOutOfStockViewController.h
//  Fount
//
//  Created by Xu Zhang on 2/1/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaruseolVIEW.h"

@interface ProductOutOfStockViewController : UIViewController<iCarouselDataSource,iCarouselDelegate>
@property (strong, nonatomic) IBOutlet UIView *stockView;
@property (strong, nonatomic) IBOutlet CaruseolVIEW *outOfStockView;
@property (strong,nonatomic) NSMutableArray *outOfStockArray;
@property (nonatomic) NSUInteger numberofScrolls;
@property (strong,nonatomic)NSString *pdpProductName;

@property (weak, nonatomic) IBOutlet UILabel *simItemLabel;
@property (nonatomic, assign) BOOL fromOut;



@end
