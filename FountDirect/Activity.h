//
//  Activity.h
//  Fount
//
//  Created by Rush on 11/27/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "Media.h"
#import "Product.h"
#import "User.h"
#import "Brand.h"
#import "Seller.h"
#import "HashTag.h"

@interface Activity : BaseModel

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) User *firstUser, *secondUser;
@property (nonatomic, strong) Brand *brand;
@property (nonatomic, strong) Seller *seller;
@property (nonatomic, strong) Hashtag *hashtag;

@property (nonatomic, strong) NSArray *arrayOfMedia;
@property (nonatomic, strong) NSArray *arrayOfproducts;


@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, assign) NSInteger activityId;
@property (nonatomic, strong) NSString *activityType;
@property (nonatomic, strong) NSString *likeEntityType;
@property (nonatomic, strong) NSString *followEntityType;

@property (nonatomic, assign) BOOL isFollowing, isPendingApproval;

@end
