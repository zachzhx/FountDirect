//
//  BaseModel.m
//  Spree
//
//  Created by Rush on 10/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

//Needs to be overwritten
-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithRequestedFollowDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
    }
    return self;
}

//Overwrite
-(NSDictionary *) dictionary {
    NSDictionary *dictionary = @{};
    
    return dictionary;
}

@end
