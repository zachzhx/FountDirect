//
//  ProductOption1Model.m
//  Spree
//
//  Created by Xu Zhang on 11/11/15.
//  Copyright © 2015 Syw. All rights reserved.
//


#import "ProductOption1Model.h"


@implementation ProductOption1Model

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    self.numberOfOptions = 1;
    
    if ([[dict objectForKey:@"dep"] objectForKey:@"option 2"]) {
        for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"option 2"]) {
            ProductOption1Model *test = [ProductOption1Model new];
            [test setValuesFromDictionary:colorDict];
            [tmpArr addObject:test];
        }
        self.numberOfOptions = 2;
    }
    else if ([[dict objectForKey:@"dep"] objectForKey:@"option 3"]) {
        for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"option 3"]) {
            ProductOption1Model *test = [ProductOption1Model new];
            [test setValuesFromDictionary:colorDict];
            [tmpArr addObject:test];
        }
        self.numberOfOptions = 3;
        
    }
    else if ([[dict objectForKey:@"dep"] objectForKey:@"option 4"]) {
        for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"option 4"]) {
            ProductOption1Model *test = [ProductOption1Model new];
            [test setValuesFromDictionary:colorDict];
            [tmpArr addObject:test];
        }
        self.numberOfOptions = 4;
        
    }
    self.subOptions = [tmpArr copy];
}

@end
