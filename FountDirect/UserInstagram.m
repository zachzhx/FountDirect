//
//  UserInstagram.m
//  Spree
//
//  Created by Rush on 10/30/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "UserInstagram.h"

@implementation UserInstagram

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        self.userProfileId              = [[dictionary objectForKey:@"id"] integerValue];
        self.instagramBio               = [dictionary objectForKey:@"instagramBio"];
        self.instagramFullName          = [dictionary objectForKey:@"instagramFullName"];
        self.instagramProfilePicture    = [dictionary objectForKey:@"instagramProfilePicture"];
        self.instagramUserName          = [dictionary objectForKey:@"instagramUserName"];
        self.instagramWebsite           = [dictionary objectForKey:@"instagramWebsite"];
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSDictionary *dictionaryToReturn = @{
                                         @"instagramUserName"       : self.instagramUserName,
                                         @"instagramBio"            : self.instagramBio,
                                         @"instagramWebsite"        : self.instagramWebsite,
                                         @"instagramProfilePicture" : self.instagramProfilePicture,
                                         @"instagramFullName"       : self.instagramFullName,
                                         @"id"                      : @(self.userProfileId)
                                         };
    return dictionaryToReturn;
}

@end
