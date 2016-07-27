//
//  Media.m
//  Spree
//
//  Created by Rush on 9/14/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "Media.h"
#import "Product.h"
#import "Comment.h"

@implementation Media

-(NSMutableArray *) arrayOfProducts {
    if (!_arrayOfProducts) {
        _arrayOfProducts = [[NSMutableArray alloc] init];
    }
    return _arrayOfProducts;
}

-(NSMutableArray *) commentsArray {
    if (!_commentsArray) {
        _commentsArray = [[NSMutableArray alloc] init];
    }
    return _commentsArray;
}

-(instancetype) initWithInstagramUserName:(NSString *) instagramUserName instagramProfileURL:(NSString *) instagramProfileURL lowRestURL:(NSString *) lowResURL standardResURL:(NSString *) standardResURL thumbnailURL:(NSString *) thumbnailURL likes:(int) likes mediaId:(int) mediaId caption:(NSString *) caption liked:(BOOL) liked {
    
    self = [super init];
    if (self) {
        self.instagramUserName = instagramUserName;
        self.instagramProfileURL = instagramProfileURL;
        self.lowResolutionURL = lowResURL;
        self.standardResolutionURL = standardResURL;
        self.thumbnailURL = thumbnailURL;
        self.likes = likes;
        self.mediaId = mediaId;
        self.caption = caption;
        self.liked = liked;
    }
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        
//        NSLog(@"DICTIONAREY:%@", dictionary);
        
        NSArray *arrayOfProductDictionary = [dictionary objectForKey:@"products"];
        
        for (NSDictionary *productDictionary in arrayOfProductDictionary) {
            Product *product = [[Product alloc] initWithDictionary:productDictionary];
            [self.arrayOfProducts addObject:product];
        }
        
        self.caption                = [dictionary objectForKey:@"caption"];
        self.mediaId                = [[dictionary objectForKey:@"id"] integerValue];
        self.instagramId            = [dictionary objectForKey:@"instagramId"];
        self.instagramUserName      = [dictionary objectForKey:@"instagramUserName"];
        self.instagramProfileURL    = [dictionary objectForKey:@"instagramUserProfileUrl"];
        self.likes                  = [[dictionary objectForKey:@"likes"] integerValue];
        self.moreLikes              = [[dictionary objectForKey:@"moreLikes"] integerValue];
        self.lowResolutionWidth     = [[dictionary objectForKey:@"lowResolutionWidth"] integerValue];
        self.lowResolutionHeight    = [[dictionary objectForKey:@"lowResolutionHeight"] integerValue];
        self.lowResolutionURL       = [dictionary objectForKey:@"lowResolutionURL"];
        
        self.standardResolutionWidth    = [[dictionary objectForKey:@"standardResolutionWidth"] integerValue];
        self.standardResolutionHeight   = [[dictionary objectForKey:@"standardResolutionHeight"] integerValue];
        self.standardResolutionURL      = [dictionary objectForKey:@"standardResolutionURL"];
        
        self.mediaType = [dictionary objectForKey:@"mediaType"];
        self.mediaOwner = [[dictionary objectForKey:@"mediaOwner"] integerValue];
        self.mediaSource = [dictionary objectForKey:@"mediaSource"];
        self.mediaUploader = [[dictionary objectForKey:@"mediaUploader"] integerValue];
        
        self.fountUserName = [dictionary objectForKey:@"fountUserName"];
        self.fountUserProfileURL = [dictionary objectForKey:@"fountUserProfileUrl"];
        
        //Video
        self.videoLowBandWidthWidth    = [[dictionary objectForKey:@"videoLowBandWidthWidth"] integerValue];
        self.videoLowBandWidthHeight   = [[dictionary objectForKey:@"videoLowBandWidthHeight"] integerValue];
        self.videoLowBandWidthURL      = [dictionary objectForKey:@"videoLowBandWidthURL"];
        
        self.videoLowResolutionWidth    = [[dictionary objectForKey:@"videoLowResolutionWidth"] integerValue];
        self.videoLowResolutionHeight   = [[dictionary objectForKey:@"videoLowResolutionHeight"] integerValue];
        self.videoLowResolutionURL      = [dictionary objectForKey:@"videoLowResolutionURL"];
        
        self.videoStandardResolutionWidth    = [[dictionary objectForKey:@"videoStandardResolutionWidth"] integerValue];
        self.videoStandardResolutionHeight   = [[dictionary objectForKey:@"videoStandardResolutionHeight"] integerValue];
        self.videoStandardResolutionURL      = [dictionary objectForKey:@"videoStandardResolutionURL"];
        
        self.tags               = [dictionary objectForKey:@"tags"];
        self.thumbnailHeight    = [[dictionary objectForKey:@"thumbnailHeight"] integerValue];
        self.thumbnailURL       = [dictionary objectForKey:@"thumbnailURL"];
        self.thumbnailWidth     = [[dictionary objectForKey:@"thumbnailWidth"] integerValue];
        
        self.liked = [[dictionary valueForKeyPath:@"socialActionUserMedia.liked"] boolValue];
        self.refountUsersCount  = [[dictionary objectForKey:@"refountUsersCount"]integerValue];
        self.arrayOfRefountUsers = [dictionary objectForKey:@"usersRefountThisMedia"];
        
        self.commentCount = [[dictionary objectForKey:@"commentsCount"] integerValue];
        
        NSArray *commentsArray = [dictionary objectForKey:@"comments"];
        
//        NSLog(@"MEDIA D:%@", dictionary);
        
        for (NSDictionary *commentDictionary in commentsArray) {
            
            Comment *comment = [[Comment alloc] initWithDictionary:[commentDictionary objectForKey:@"commentJson"]];
            comment.mediaId = self.mediaId;
            
            comment.user = [[User alloc] initWithDictionary:[commentDictionary valueForKeyPath:@"userJson"]];
            comment.metadataMapsDictionary = [commentDictionary objectForKey:@"metadataMaps"];
            
            [self.commentsArray addObject:comment];
        }
    }
    return self;
}

//-(void) createCharArray:(NSString*) text{
//    char arr[text.length];
//    for(int i=0;i<text.length;i++){
//        arr[i]=[text characterAtIndex:i];
//    }
//}

@end
