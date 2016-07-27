//
//  Address.m
//  Spree
//
//  Created by Rush on 11/5/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "Address.h"

@implementation Address

-(instancetype)initWithAddressLine1:(NSString *) addressLine1 name:(NSString *) name city:(NSString *) city state:(NSString *) state zip:(NSString *) zip phoneNumber:(NSString *) phoneNumber type:(NSString *) type {
    self = [super init];
    if (self) {
        self.line1 = addressLine1;
        self.name = name;
        self.city = city;
        self.state = state;
        self.zip = zip;
        self.phoneNumber = phoneNumber;
        self.type = type;
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        self.addressId = [[dictionary objectForKey:@"id"] integerValue];
        self.name   = [dictionary objectForKey:@"name"];
        self.line1  = [dictionary objectForKey:@"line1"];
        self.city   = [dictionary objectForKey:@"city"];
        self.state  = [dictionary objectForKey:@"state"];
        self.zip    = [dictionary objectForKey:@"zip"];
        self.type   = [dictionary objectForKey:@"type"];
        
        self.phoneNumber  = [dictionary objectForKey:@"phone"];
        
        self.user   = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
    }
    return self;
}

-(NSDictionary *) dictionary {
    NSDictionary *addressDictionary = @{
                                        @"line1": self.line1,
                                        @"name": self.name,
                                        @"city": self.city,
                                        @"state": self.state,
                                        @"zip": self.zip,
                                        @"phone": self.phoneNumber,
                                        @"type": self.type
                                        };
    
    NSMutableDictionary *mutableaddressDictionary = [addressDictionary mutableCopy];
    
    if (self.line2) {
        [mutableaddressDictionary setObject:self.line2 forKey:@"line2"];
    }
    
    return [mutableaddressDictionary copy];
}

@end
