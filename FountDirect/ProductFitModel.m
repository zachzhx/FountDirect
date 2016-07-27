//
//  ProductFitModel.m
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "ProductFitModel.h"
#import "ProductColorModel.h"
#import "ProductSizeModel.h"

@implementation ProductFitModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"color"]) {
        ProductColorModel *colorModel = [ProductColorModel new];
        [colorModel setValuesFromDictionary:colorDict];
        [tmpArr addObject:colorModel];
    }
    self.colors = [tmpArr copy];
    
    self.extraInfo = [dict objectForKey:@"extra_info"];
    self.image = [dict objectForKey:@"image"];
    self.price = [dict objectForKey:@"price"];
    self.text = [dict objectForKey:@"text"];
    self.value = [dict objectForKey:@"value"];
    
}

@end
