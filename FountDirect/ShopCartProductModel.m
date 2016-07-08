//
//  ShopCartProductModel.m
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ShopCartProductModel.h"
#import "CartProductMetaData.h"
#import "CartProductModel.h"

@implementation ShopCartProductModel
@synthesize quantity;
@synthesize shippingMethod;
@synthesize product, cartProductMetadata;

+ (NSMutableArray*)getProductData:(NSArray*)dataArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dictResSub in dataArray)
    {
        //Properties that tell which form this FormItem(Question) belongs to
        
//        NSLog(@"getProductData dict:%@", dictResSub);
        
        ShopCartProductModel *cart = [[ShopCartProductModel alloc] init];
        cart.quantity = [dictResSub valueForKey:@"quantity"];
        cart.shippingMethod =   [dictResSub valueForKey:@"shippingMethod"];
        cart.product = [CartProductModel getCartProduct:[dictResSub valueForKey:@"product"]];
        cart.cartProductMetadata = [CartProductMetaData getProductMetaData:[dictResSub valueForKey:@"productMetadata"]];//For ShoppingCart Product Metadata
        cart.cartProductId = [dictResSub valueForKey:@"id"];
        cart.productDict = [dictResSub objectForKey:@"product"];
        cart.productMetadata = [[ProductMetadata alloc] initWithDictionary:[dictResSub objectForKey:@"productMetadata"]];
        
        [array addObject:cart];
    }
    //  NSLog(@"shop: %@",array);
    return array;
}

@end