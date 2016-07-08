//
//  chatUser.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "chatUser.h"

@implementation chatUser

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        
        if ([[dictionary valueForKey:@"user"]count] > 0) {
            
            self.profilePicture     = [dictionary valueForKeyPath:@"user.userProfile.profilePicture"];
            self.privateSetting = [[dictionary valueForKeyPath:@"user.userProfile.privateSetting"] boolValue];
            self.fullName = [dictionary valueForKeyPath:@"user.userProfile.fullName"];
            self.bio = [dictionary valueForKeyPath:@"user.userProfile.bio"];
            self.displayName    = [dictionary valueForKeyPath:@"user.displayName"];
            self.entityName     = [dictionary valueForKeyPath:@"user.entityName"];
            self.userId         = [[dictionary valueForKeyPath:@"user.id"] integerValue];
            self.confirmRegistrationStatus = [[dictionary valueForKeyPath:@"user.confirmRegistrationStatus"] boolValue];
            self.isDeleted = [[dictionary objectForKey:@"isDeleted"]boolValue];

        }else{
            self.displayName    = [dictionary valueForKeyPath:@"displayName"];
            self.entityName     = [dictionary valueForKeyPath:@"entityName"];
            self.userId         = [[dictionary valueForKeyPath:@"id"] integerValue];
            self.confirmRegistrationStatus = [[dictionary valueForKeyPath:@"user.confirmRegistrationStatus"] boolValue];
            self.profilePicture     = [dictionary valueForKeyPath:@"userProfile.profilePicture"];
            self.privateSetting = [[dictionary valueForKeyPath:@"userProfile.privateSetting"] boolValue];
            self.fullName = [dictionary valueForKeyPath:@"userProfile.fullName"];
            self.bio = [dictionary valueForKeyPath:@"userProfile.bio"];
        }
        
    }
    return self;
}

@end
