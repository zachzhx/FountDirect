//
//  User.m
//  Spree
//
//  Created by Rush on 10/12/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "User.h"
#import "Constants.h"

@implementation User

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        
//        NSLog(@"USER DICT:%@", dictionary);
        
        self.displayName    = [dictionary objectForKey:@"displayName"];
        self.email          = [dictionary objectForKey:@"email"];
        self.entityName     = [dictionary objectForKey:@"entityName"];
        self.userId         = [[dictionary objectForKey:@"id"] integerValue];
        self.userInstagram    = [[UserInstagram alloc] initWithDictionary:[dictionary objectForKey:@"userInstagram"]];
        
        self.facebookAccessToken    = [dictionary objectForKey:@"facebookAccessToken"];
        self.facebookUserId         = [[dictionary objectForKey:@"facebookUserId"] integerValue];
        self.instagramAccessToken   = [dictionary objectForKey:@"instagramAccessToken"];
        self.instagramUserId        = [[dictionary objectForKey:@"instagramUserId"] integerValue];
        self.isFacebookLinked       = [[dictionary objectForKey:@"isFacebookLinked"] boolValue];
        self.isInstagramLinked      = [[dictionary objectForKey:@"isInstagramLinked"] boolValue];
        self.profilePicture     = [dictionary valueForKeyPath:@"userProfile.profilePicture"];
        self.privateSetting = [[dictionary valueForKeyPath:@"userProfile.privateSetting"] boolValue];
        
        if ([self.entityName isEqualToString:kBrandEntityName]) {
//            self.imageURL = [dictionary objectForKey:@"imageUrl"];
//            self.profilePicture = [dictionary objectForKey:@"imageUrl"];
            
            NSString *localImageURL = [dictionary objectForKey:@"localImageUrl"];
            
            self.profilePicture = localImageURL;
            
            if (localImageURL.length == 0) {
                self.profilePicture = [dictionary objectForKey:@"imageUrl"];
            }
            
            self.displayName = [dictionary objectForKey:@"name"];
        }
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSDictionary *dictionaryToReturn = @{
                                         @"email"               : self.email,
                                         @"displayName"         : self.displayName,
                                         @"isInstagramLinked"   : @(self.isInstagramLinked),
                                         @"instagramUserId"     : @(self.instagramUserId),
                                         @"instagramAccessToken": self.instagramAccessToken,
                                         @"userInstagram"         : [self.userInstagram dictionary],
                                         @"isFacebookLinked"    : @(self.isFacebookLinked),
                                         @"entityName"          : self.entityName,
                                         @"id"                  : @(self.userId)
                                         };
    
    return dictionaryToReturn;
}

@end
