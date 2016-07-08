//
//  ProductMetadata.m
//  Fount
//
//  Created by Rush on 4/5/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ProductMetadata.h"

@implementation ProductMetadata

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    
    if (self) {
        self.availability = [dictionary objectForKey:@"availability"];
        self.productMetadataId = [[dictionary objectForKey:@"id"] integerValue];
        self.price = [[dictionary objectForKey:@"price"] floatValue];
        self.shopperPoints = [[dictionary objectForKey:@"shopperPoints"] integerValue];
        
        NSArray *keysArray = [dictionary allKeys];
        
        int count = 0;
        
        for (int i = 0; i < keysArray.count; i++) {
            NSString *key = keysArray[i];
            
            if (![key isEqualToString:@"availability"] && ![key isEqualToString:@"id"] && ![key isEqualToString:@"price"] && ![key isEqualToString:@"shopperPoints"]) {
                
                if (count == 0) {
                    self.option1Dictionary = @{key : [dictionary objectForKey:key]};
                } else if (count == 1) {
                    self.option2Dictionary = @{key : [dictionary objectForKey:key]};
                } else if (count == 2) {
                    self.option3Dictionary = @{key : [dictionary objectForKey:key]};
                } else if (count == 3) {
                    self.option4Dictionary = @{key : [dictionary objectForKey:key]};
                }
                count++;
            }
        }
        
//        for (NSString *key in keysArray) {
//            if (![key isEqualToString:@"availability"] || ![key isEqualToString:@"id"] || ![key isEqualToString:@"price"]) {
//                
//            }
//        }
    }
    return self;
}

@end
