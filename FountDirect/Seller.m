//
//  Seller.m
//  Spree
//
//  Created by Rush on 10/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "Seller.h"

@implementation Seller

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.quality = [dictionary objectForKey:@"quality"];
        self.sellerId = [[dictionary objectForKey:@"id"] integerValue];
        self.productsCount = [[dictionary objectForKey:@"productsCount"] integerValue];
        self.isSelected = [[dictionary objectForKey:@"selected"] boolValue];
//        self.imageURL = [dictionary objectForKey:@"imageUrl"];
        self.imageURL = [dictionary objectForKey:@"localImageUrl"];
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"sellerId: %tu, name: %@, quality: %@, productsCount: %tu, isSelected: %i", self.sellerId, self.name, self.quality, self.productsCount, self.isSelected];
}

-(NSDictionary *) dictionary {
    NSDictionary *dictionaryToReturn = @{
                                        @"name": self.name,
                                        @"quality": self.quality,
                                        @"id": @(self.sellerId),
                                        };
    return dictionaryToReturn;
}

@end
