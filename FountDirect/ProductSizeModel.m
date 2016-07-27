//
//  ProductSizeModel.m
//  Spree
//
//  Created by Xu Zhang on 11/11/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductSizeModel.h"

@implementation ProductSizeModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    
    if ([[dict objectForKey:@"dep"] objectForKey:@"inseam"]) {
        for (NSDictionary *sizeDict in [[dict objectForKey:@"dep"] objectForKey:@"inseam"]) {
            BaseProductAttributeModel *inseamModel = [ProductSizeModel new];
            [inseamModel setValuesFromDictionary:sizeDict];
            [tmpArr addObject:inseamModel];
        }
    }
    self.inseam = [tmpArr copy];
}

@end
