//
//  Order.h
//  Fount
//
//  Created by Rush on 4/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface Order : BaseModel

@property (nonatomic, strong) NSString *orderDate;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *status;

@property (nonatomic, assign) NSInteger orderId, orderItemsCount, bucket;
@property (nonatomic, assign) CGFloat totalPrice;


@end
