//
//  ProductStyleModel.m
//  Spree
//
//  Created by Xu Zhang on 11/12/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductStyleModel.h"

@implementation ProductStyleModel
- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    
    if ([[dict objectForKey:@"dep"] objectForKey:@"inseam"] ||! [[dict objectForKey:@"dep"] isKindOfClass:[NSNull class]]) {
        for (NSDictionary *sizeDict in [[dict objectForKey:@"dep"] objectForKey:@"inseam"]) {
            BaseProductAttributeModel *inseamModel = [ProductStyleModel new];
            [inseamModel setValuesFromDictionary:sizeDict];
            [tmpArr addObject:inseamModel];
        }
    }else{
        BaseProductAttributeModel *inseamModel = [ProductStyleModel new];
        [inseamModel setValuesFromDictionary:dict];
        [tmpArr addObject:inseamModel];
        
    }
    self.inseam = [tmpArr copy];
  
}

@end
