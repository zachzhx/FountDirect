//
//  Notification.m
//  Fount
//
//  Created by Rush on 4/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "Notification.h"
#import "Constants.h"

@implementation Notification

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        self.firstUser  = [[User alloc] initWithDictionary:[dictionary objectForKey:@"initiator"]];
        self.message = [dictionary objectForKey:@"message"];
        self.notificationId = [[dictionary objectForKey:@"id"] integerValue];
        self.creationDate = [dictionary objectForKey:@"creationDate"];

        self.notificationType = [dictionary objectForKey:@"notificationType"];
        
        if ([self.notificationType isEqualToString:kNotificationTypeLikePost] || [self.notificationType isEqualToString:kNotificationTypeProductTaggedInMedia] || [self.notificationType isEqualToString:kNotificationTypeCommentMention] || [self.notificationType isEqualToString:kNotificationTypeCommentMedia]) {
            
            self.media = [[Media alloc] initWithDictionary:[dictionary objectForKey:@"media"]];
        }
        
        if ([self.notificationType isEqualToString:@"ORDER"]) {
            self.order = [[Order alloc] initWithDictionary:[dictionary objectForKey:@"order"]];
        }
        
        if ([self.notificationType isEqualToString:@"PRODUCTS_TAGGED_IN_MEDIA"] || [self.notificationType isEqualToString:@"PRODUCTS_TAGGED_IN_VT"]) {
            
            NSMutableArray *mutableArrayOfProducts = [[NSMutableArray alloc] init];
            
            NSArray *mutableArrayOfProductDictionaries = [dictionary objectForKey:@"products"];
            
            for (NSDictionary *productDictionary in mutableArrayOfProductDictionaries) {
                Product *product = [[Product alloc] initWithDictionary:productDictionary];
                
                [mutableArrayOfProducts addObject:product];
            }
            
            self.arrayOfproducts = mutableArrayOfProducts;
        }
        
        if ([self.notificationType isEqualToString:@"FOLLOW"]) {

            self.isFollowing = [[dictionary valueForKeyPath:@"socialActionUserFollowerJson.follow"] boolValue];
            self.isPendingApproval = [[dictionary valueForKeyPath:@"socialActionUserFollowerJson.isApprovalPending"] boolValue];
        }
        
        if ([self.notificationType isEqualToString:kNotificationTypeCommentMention] || [self.notificationType isEqualToString:kNotificationTypeCommentMedia]) {
            
//            NSLog(@"NOT DIC:%@", dictionary);
            
            self.comment = [[Comment alloc] initWithDictionary:[dictionary objectForKey:@"comment"]];
            self.comment.metadataMapsDictionary = [dictionary objectForKey:@"metadataMaps"];
            
//            NSLog(@"COMM:%@", [dictionary objectForKey:@"comment"]);
        }
    }
    return self;
}

@end
