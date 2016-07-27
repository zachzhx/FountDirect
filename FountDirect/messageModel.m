//
//  messageModel.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "messageModel.h"
#import "Product.h"

@implementation messageModel


-(NSMutableArray *) arrayOfProducts {
    if(!_arrayOfProducts){
        _arrayOfProducts = [[NSMutableArray alloc]init];
    }
    return _arrayOfProducts;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if(self){
        
        NSArray *arrayOfProductDictionary;
        
        if ([[dictionary objectForKey:@"type"] isEqualToString:@"PRODUCTS"]) {
            arrayOfProductDictionary = [dictionary valueForKey:@"products"];
            NSDictionary *singleProductDictionary = [[arrayOfProductDictionary objectAtIndex:0]valueForKey:@"product"];
            self.arrayOfRelevantMedias = [[arrayOfProductDictionary objectAtIndex:0]valueForKey:@"relevantMedia"];
            Product *product = [[Product alloc] initWithDictionary:singleProductDictionary];
            [self.arrayOfProducts addObject:product];
        }
        
        if ([[dictionary objectForKey:@"type"] isEqualToString:@"MEDIA"]) {
            arrayOfProductDictionary = [dictionary valueForKeyPath:@"media.products"];
            for (NSDictionary *productDictionary in arrayOfProductDictionary) {
                Product *product = [[Product alloc] initWithDictionary:productDictionary];
                [self.arrayOfProducts addObject:product];
            }
        }
        
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
        
        //MEDIA
        if ([self.type isEqualToString:@"MEDIA"]) {
        self.mediaDictionary = [dictionary valueForKey:@"media"];
        self.mediaCaption                = [dictionary valueForKeyPath:@"media.caption"];
        self.mediaId                = [[dictionary valueForKeyPath:@"media.id"] integerValue];
        self.mediaType = [dictionary valueForKeyPath:@"media.mediaType"];
        self.mediaOwner = [[dictionary valueForKeyPath:@"media.mediaOwner"] integerValue];
        self.mediaSource = [dictionary valueForKeyPath:@"media.mediaSource"];
        self.mediaUploader = [[dictionary valueForKeyPath:@"media.mediaUploaded"] integerValue];
        self.mediaTags = [dictionary valueForKeyPath:@"media.tags"];
        self.mediaStandardResolutionWidth    = [[dictionary valueForKeyPath:@"media.standardResolutionWidth"] integerValue];
        self.mediaStandardResolutionHeight   = [[dictionary valueForKeyPath:@"media.standardResolutionHeight"] integerValue];
        self.mediaStandardResolutionURL      = [dictionary valueForKeyPath:@"media.standardResolutionURL"];
        self.mediaIgUploaderProfileUrl = [dictionary valueForKeyPath:@"media.instagramUserProfileUrl"];
        self.mediaIgUploaderName = [dictionary valueForKeyPath:@"media.instagramUserName"];
        self.mediaFountUploaderProfileUrl = [dictionary valueForKeyPath:@"media.fountUserProfileUrl"];
        self.mediaFountUploaderName = [dictionary valueForKeyPath:@"media.fountUserName"];
        }
        
        //For Post Message:
//        self.type = [dictionary valueForKeyPath:@"message.type"];
//        self.textContent = [dictionary valueForKeyPath:@"message.textContent"];
//        self.isVisible = [[dictionary valueForKeyPath:@"message.isVisible"]boolValue];
//        self.timePassed = [dictionary objectForKey:@"timePassed"];

    }
    return self;
}


@end
