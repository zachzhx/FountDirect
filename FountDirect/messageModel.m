//
//  messageModel.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "messageModel.h"

@implementation messageModel

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if(self){
        
        self.type = [dictionary objectForKey:@"type"];
        self.textContent = [dictionary objectForKey:@"textContent"];
        self.isVisible = [[dictionary objectForKey:@"isVisible"]boolValue];
        self.timePassed = [dictionary objectForKey:@"timePassed"];
        
        self.fromUserDisplayName = [dictionary valueForKeyPath:@"from.displayName"];
        self.confirmRegistrationStatus = [[dictionary valueForKeyPath:@"from.confirmRegistrationStatus"]boolValue];
        self.entityName = [dictionary valueForKeyPath:@"from.entityName"];
        self.fromUserId = [[dictionary valueForKeyPath:@"from.id"]integerValue];
        
        self.fromProfilePicture = [dictionary valueForKeyPath:@"from.userProfile.profilePicture"];
        self.fromPrivateSetting = [[dictionary valueForKeyPath:@"from.userProfile.privateSetting"]boolValue];
        self.fromFullName = [dictionary valueForKeyPath:@"from.userProfile.fullName"];
        self.fromBio = [dictionary valueForKeyPath:@"from.userProfile.bio"];
        
        //For Post Message:
//        self.type = [dictionary valueForKeyPath:@"message.type"];
//        self.textContent = [dictionary valueForKeyPath:@"message.textContent"];
//        self.isVisible = [[dictionary valueForKeyPath:@"message.isVisible"]boolValue];
//        self.timePassed = [dictionary objectForKey:@"timePassed"];

    }
    return self;
}


@end
