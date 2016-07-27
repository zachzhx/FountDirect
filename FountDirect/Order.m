//
//  Order.m
//  Fount
//
//  Created by Rush on 4/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "Order.h"

@implementation Order

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        self.status = [dictionary objectForKey:@"status"];
        self.orderDate = [dictionary objectForKey:@"date"];
        self.imageURL = [dictionary objectForKey:@"imageURL"];
        
        self.orderId = [[dictionary objectForKey:@"id"] integerValue];
        self.orderItemsCount = [[dictionary objectForKey:@"orderItemsCount"] integerValue];
        self.bucket = [[dictionary objectForKey:@"bucket"] integerValue];
        self.totalPrice = [[dictionary objectForKey:@"totalPrice"] floatValue];
    }
    return self;
}

@end
