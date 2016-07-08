//
//  ShoppingCartProduct.m
//  Spree
//
//  Created by Rush on 10/30/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ShoppingCartProduct.h"

@implementation ShoppingCartProduct

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        self.product = [[Product alloc] initWithDictionary:[dictionary objectForKey:@"product"]];
        
        self.shoppingCartProductId = [[dictionary objectForKey:@"id"] integerValue];
        self.quantity = [[dictionary objectForKey:@"quantity"] integerValue];
        self.shippingMethod = [dictionary objectForKey:@"shippingMethod"];
        
        self.productMetadata = [[ProductMetadata alloc] initWithDictionary:[dictionary objectForKey:@"productMetadata"]];
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSDictionary *dictionaryToReturn = @{
                                         @"0": [self.product dictionary]
                                         };
    return dictionaryToReturn;
}

@end
