//
//  ProductFlavorModel.m
//  Fount
//
//  Created by Zhang Xu on 12/4/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductFlavorModel.h"

@implementation ProductFlavorModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    for (NSDictionary *flavorDict in [[dict objectForKey:@"dep"] objectForKey:@"size"]) {
        BaseProductAttributeModel *sizeModel = [ProductFlavorModel new];
        [sizeModel setValuesFromDictionary:flavorDict];
        [tmpArr addObject:sizeModel];
    }
    self.sizes = [tmpArr copy];
}


@end
