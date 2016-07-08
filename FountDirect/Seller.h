//
//  Seller.h
//  Spree
//
//  Created by Rush on 10/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface Seller : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *quality;
@property (nonatomic, assign) NSInteger sellerId;
@property (nonatomic, assign) NSInteger productsCount;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *imageURL;

@end
