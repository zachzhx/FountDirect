//
//  chatGroupModel.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "chatGroupModel.h"

@implementation chatGroupModel

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    self.usersMutableArray = [NSMutableArray new];
    
    if (self) {
        self.id = [[dictionary objectForKey:@"id"]integerValue];
        self.names = [dictionary objectForKey:@"name"];
        self.type = [dictionary objectForKey:@"type"];
        
        NSArray *usersArray = [dictionary objectForKey:@"users"];
        for (NSDictionary *userDict in usersArray){
            chatUser *singleUser = [[chatUser alloc]initWithDictionary:userDict];
            [self.usersMutableArray addObject:singleUser];
        }
    }
    return self;
}

@end
