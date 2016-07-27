//
//  Tag.m
//  Spree
//
//  Created by Rush on 9/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "VisualTag.h"

@implementation VisualTag

-(NSMutableArray<Product> *)arrayOfProducts {
    if (!_arrayOfProducts) {
        _arrayOfProducts = [[NSMutableArray<Product> alloc] init];
    }
    return _arrayOfProducts;
}

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        
        self.xPosition = [[dictionary objectForKey:@"percentageX"] floatValue];
        self.yPosition = [[dictionary objectForKey:@"percentageY"] floatValue];
        self.visualTagId = [[dictionary objectForKey:@"id"] integerValue];
        self.isVisible = [[dictionary objectForKey:@"isVisible"] boolValue];
        
        NSArray *productsArray = [dictionary objectForKey:@"products"];
        
        for (NSDictionary *productDictionary in productsArray) {
            Product *product = [[Product alloc] initWithDictionary:productDictionary];
            [self.arrayOfProducts addObject:product];
        }
        
        self.productTagger = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSDictionary *dictionaryToReturn = @{
                                         @"percentageX": @(self.xPosition),
                                         @"percentageY": @(self.yPosition),
                                         @"isVisible": @(self.isVisible),
                                         @"id": @(self.visualTagId)
                                         };
    return dictionaryToReturn;
}

@end
