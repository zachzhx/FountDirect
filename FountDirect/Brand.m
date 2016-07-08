//
//  Brand.m
//  Spree
//
//  Created by Rush on 10/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "Brand.h"

@implementation Brand

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.entityName = [dictionary objectForKey:@"entityName"];
        self.brandId = [[dictionary objectForKey:@"id"] integerValue];
//        self.imageURL = [dictionary objectForKey:@"imageURL"];
        self.imageURL = [dictionary objectForKey:@"localImageUrl"];
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSDictionary *dictionaryToReturn = @{
                                         @"name": self.name,
                                         @"entityName": self.entityName,
                                         @"id": @(self.brandId)
                                         };
    return dictionaryToReturn;
}

@end
