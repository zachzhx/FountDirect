//
//  Activity.m
//  Fount
//
//  Created by Rush on 11/27/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "Activity.h"
#import "Constants.h"

@implementation Activity

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
//        NSError * err;
//        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
//        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//         NSLog(@"act dict:%@", myString);
        self.media      = [[Media alloc] initWithDictionary:[dictionary objectForKey:@"media"]];
        self.product    = [[Product alloc] initWithDictionary:[dictionary objectForKey:@"product"]];
        
        self.firstUser  = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        
//        NSLog(@"PATH:%@", [dictionary objectForKey:@"user"]);
        
//        NSLog(@"NAME:%@ -- PP:%@", self.firstUser.displayName, [dictionary valueForKeyPath:@"user.profilePicture"]);
        
        self.firstUser.userInstagram.instagramProfilePicture = [dictionary valueForKeyPath:@"user.profilePicture"];
        
//        NSLog(@"USER IG:%@", self.firstUser.userInstagram.instagramProfilePicture);
        
        self.message        = [dictionary objectForKey:@"message"];
        self.activityId     = [[dictionary objectForKey:@"id"] integerValue];
        self.creationDate   = [dictionary objectForKey:@"creationDate"];
        
        self.activityType   = [dictionary objectForKey:@"activityType"];
        
        if ([self.activityType isEqualToString:kActivityTypeLike]) {
            self.likeEntityType = [dictionary objectForKey:@"likeEntityType"];
            
            if ([self.likeEntityType isEqualToString:kLikeEntityTypeMedia]) {
                self.secondUser = [[User alloc] initWithDictionary:[dictionary objectForKey:@"mediaOwner"]];
            }
            
        } else if ([self.activityType isEqualToString:kActivityTypeFollow]) {
            self.followEntityType = [dictionary objectForKey:@"followEntityType"];
            self.secondUser = [[User alloc] initWithDictionary:[dictionary objectForKey:@"followee"]];
            
            self.isPendingApproval = [[dictionary valueForKeyPath:@"socialActionUserFollower.isApprovalPending"] boolValue];
            
            if ([self.followEntityType isEqualToString:kFollowEntityTypeBrand]) {
                self.brand = [[Brand alloc] initWithDictionary:[dictionary objectForKey:@"brand"]];
                self.isFollowing = [[dictionary valueForKeyPath:@"socialActionUserBrand.follow"] boolValue];
                
            }else if([self.followEntityType isEqualToString:kFollowEntityTypeSeller]){
                self.seller = [[Seller alloc] initWithDictionary:[dictionary objectForKey:@"seller"]];
                self.isFollowing = [[dictionary valueForKeyPath:@"socialActionUserSeller.follow"] boolValue];
                
            }else if([self.followEntityType isEqualToString:KFollowEntityTypeHashtag]){
                self.hashtag = [[Hashtag alloc]initWithDictionary:[dictionary objectForKey:@"hashtag"]];
                self.isFollowing = [[dictionary valueForKeyPath:@"socialActionUserHashtag.follow"]boolValue];
            }
            else {
                self.isFollowing = [[dictionary valueForKeyPath:@"socialActionUserFollower.follow"] boolValue];
            }
        }
        
#pragma mark Imports
        if ([self.activityType isEqualToString:kActivityTypeImport]) {
            
            NSMutableArray *mutableArrayOfMedia = [[NSMutableArray alloc] init];
            
            NSArray *arrayOfMediaData = [dictionary objectForKey:@"medias"];
            
            for (NSDictionary *mediaDictionary in arrayOfMediaData) {
                Media *media = [[Media alloc] initWithDictionary:mediaDictionary];
                
                [mutableArrayOfMedia addObject:media];
            }
            
            self.arrayOfMedia = mutableArrayOfMedia;
            
           // NSLog(@"arrayOfMedia:%@",_arrayOfMedia);
        }
#pragma mark tags
        if ([self.activityType isEqualToString:kActivityTypeVT]) {
            
            self.firstUser  = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
            self.secondUser = [[User alloc] initWithDictionary:[dictionary objectForKey:@"visualTagOwner"]];
            
            NSMutableArray *mutableArrayOfMedia = [[NSMutableArray alloc] init];
            
            NSArray *arrayOfMediaData = [dictionary objectForKey:@"products"];
            
            for (NSDictionary *mediaDictionary in arrayOfMediaData) {
                Product *product = [[Product alloc] initWithDictionary:mediaDictionary];
                
                [mutableArrayOfMedia addObject:product];
            }
            self.firstUser.userInstagram.instagramProfilePicture = [dictionary valueForKeyPath:@"user.profilePicture"];
            self.arrayOfproducts = mutableArrayOfMedia;
        }
        if ([self.activityType isEqualToString:kActivityTypeMedia]) {
            
            self.firstUser  = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
            self.secondUser = [[User alloc] initWithDictionary:[dictionary objectForKey:@"mediaOwner"]];
            
            NSMutableArray *mutableArrayOfMedia = [[NSMutableArray alloc] init];
            
            NSArray *arrayOfMediaData = [dictionary objectForKey:@"products"];
            
            for (NSDictionary *mediaDictionary in arrayOfMediaData) {
                Product *product = [[Product alloc] initWithDictionary:mediaDictionary];
                
                [mutableArrayOfMedia addObject:product];
            }
            self.firstUser.userInstagram.instagramProfilePicture = [dictionary valueForKeyPath:@"user.profilePicture"];
            self.arrayOfproducts = mutableArrayOfMedia;
        }
    }
    return self;
}

@end
