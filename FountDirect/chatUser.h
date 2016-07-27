//
//  chatUser.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface chatUser : BaseModel

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) BOOL confirmRegistrationStatus;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSString *profilePicture;
@property (nonatomic, assign) BOOL privateSetting;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, assign) BOOL isDeleted;

@property (nonatomic, assign) NSInteger numOfUnreadMsg;
@end
