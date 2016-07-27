//
//  ProductOptionModel.m
//  Spree
//
//  Created by Zhang Xu on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductOptionModel.h"

@implementation ProductOptionModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *arr = [NSMutableArray new];
    for (NSDictionary *subDict in dict) {
        BaseProductAttributeModel *model = [BaseProductAttributeModel new];
        [model setValuesFromDictionary:subDict];
        [arr addObject:model];
    }
    self.options = [arr copy];
}

@end
