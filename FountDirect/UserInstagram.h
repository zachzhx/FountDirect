//
//  UserInstagram.h
//  Spree
//
//  Created by Rush on 10/30/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface UserInstagram : BaseModel

@property (nonatomic, assign) NSInteger userProfileId;
@property (nonatomic, strong) NSString *instagramBio;
@property (nonatomic, strong) NSString *instagramFullName;
@property (nonatomic, strong) NSString *instagramProfilePicture;
@property (nonatomic, strong) NSString *instagramUserName;
@property (nonatomic, strong) NSString *instagramWebsite;

@end
