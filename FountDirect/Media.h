//
//  Media.h
//  Spree
//
//  Created by Rush on 9/14/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "BaseModel.h"


@interface Media : BaseModel

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, assign) NSInteger mediaId;
@property (nonatomic, assign) NSInteger mediaOwner, mediaUploader;
@property (nonatomic, strong) NSString *instagramId;
@property (nonatomic, strong) NSString *instagramUserName;
@property (nonatomic, strong) NSString *instagramProfileURL;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger moreLikes;
@property (nonatomic, strong) NSString *locationName;

@property (nonatomic, assign) NSInteger lowResolutionWidth;
@property (nonatomic, assign) NSInteger lowResolutionHeight;
@property (nonatomic, strong) NSString *lowResolutionURL;

@property (nonatomic, assign) NSInteger standardResolutionWidth;
@property (nonatomic, assign) NSInteger standardResolutionHeight;
@property (nonatomic, strong) NSString *standardResolutionURL;

@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSString *mediaSource;

@property (nonatomic, strong) NSString *fountUserName;
@property (nonatomic, strong) NSString *fountUserProfileURL;

@property (nonatomic, strong) NSString *videoLowBandWidthURL, *videoLowResolutionURL, *videoStandardResolutionURL;
@property (nonatomic, assign) NSInteger videoLowBandWidthWidth, videoLowResolutionWidth, videoStandardResolutionWidth;
@property (nonatomic, assign) NSInteger videoLowBandWidthHeight, videoLowResolutionHeight, videoStandardResolutionHeight;

@property (nonatomic, strong) NSString *tags;

@property (nonatomic, assign) NSInteger thumbnailHeight;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, assign) NSInteger thumbnailWidth;

@property (nonatomic, assign) BOOL liked;

@property (nonatomic, strong) NSArray *fourImagesArray;
@property (nonatomic, strong) NSMutableArray *commentsArray;

@property (nonatomic, assign) float horizantalOffset;
@property (nonatomic, strong) NSMutableArray *arrayOfProducts;

@property (nonatomic, assign) NSInteger commentCount;

-(instancetype) initWithInstagramUserName:(NSString *) instagramUserName instagramProfileURL:(NSString *) instagramProfileURL lowRestURL:(NSString *) lowResURL standardResURL:(NSString *) standardResURL thumbnailURL:(NSString *) thumbnailURL likes:(int) likes mediaId:(int) mediaId caption:(NSString *) caption liked:(BOOL) liked;

//Refount:
@property (nonatomic, assign) NSInteger refountUsersCount;
@property (nonatomic, strong) NSMutableArray *arrayOfRefountUsers;


@end