//
//  User.h
//  Spree
//
//  Created by Rush on 10/12/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "UserInstagram.h"

@interface User : BaseModel

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *facebookAccessToken;
@property (nonatomic, assign) NSInteger facebookUserId;
@property (nonatomic, strong) NSString *instagramAccessToken;
@property (nonatomic, assign) NSInteger instagramUserId;
@property (nonatomic, strong) NSString *profilePicture;

@property (nonatomic, assign) BOOL isFacebookLinked;
@property (nonatomic, assign) BOOL isInstagramLinked;
@property (nonatomic, assign) BOOL privateSetting;

@property (nonatomic, strong) UserInstagram *userInstagram;

@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) BOOL isPendingApproval;

@property (nonatomic, assign) BOOL isABrand;
@property (nonatomic, assign) BOOL isASeller;

//Used for brand imageURL
@property (nonatomic, strong) NSString *imageURL;

@end
