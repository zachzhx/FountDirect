//
//  ShopCartProductModel.h
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductMetadata.h"

@interface ShopCartProductModel : NSObject
@property(strong,nonatomic)NSString *quantity;
@property(strong,nonatomic)NSString *shippingMethod;
@property(strong,nonatomic)NSArray *product,*cartProductMetadata;
@property(strong,nonatomic)NSString *cartProductId;
@property (strong,nonatomic)NSDictionary *productDict;

@property (nonatomic, strong) ProductMetadata *productMetadata;

+(NSMutableArray*)getProductData:(NSArray*)dataArray;

@end
