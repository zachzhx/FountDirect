//
//  CartProductModel.m
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "CartProductModel.h"

@implementation CartProductModel
@synthesize aId,aPrice,aSalePrice,aFinalPrice,aRetailPrice,aDescription;
@synthesize inStock;
@synthesize name,imageURL;
@synthesize seller,category,brand;

+ (NSMutableArray*)getCartProduct:(NSDictionary*)dataDict{
    
    //NSLog(@"dataDict 2 :%@",dataArray);
    
    NSMutableArray *array = [NSMutableArray array];
    
    CartProductModel *aProduct = [[CartProductModel alloc] init];
    aProduct.name = [dataDict valueForKey:@"name"];
    aProduct.aDescription = [dataDict valueForKey:@"description"];
    aProduct.imageURL = [dataDict valueForKey:@"imageURL"];
    aProduct.aId = [dataDict valueForKey:@"id"];
    aProduct.aPrice = [dataDict valueForKey:@"price"];
    aProduct.aSalePrice = [dataDict valueForKey:@"sale"];
    aProduct.aRetailPrice = [dataDict valueForKey:@"retailPrice"];
    aProduct.aFinalPrice = [dataDict valueForKey:@"finalPrice"];
    aProduct.inStock = [[dataDict objectForKey:@"inStock"] boolValue];
    aProduct.seller = [dataDict valueForKey:@"seller"];
    aProduct.brand = [dataDict valueForKey:@"brand"];
    aProduct.category = [dataDict valueForKey:@"category"];
    aProduct.shopperPoints = [[dataDict valueForKey:@"shopperPoints"]integerValue];
    
    [array addObject:aProduct];
    //  NSLog(@"cart: %@",array);
    return array;
}

@end
