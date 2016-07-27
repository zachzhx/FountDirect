//
//  Comment.h
//  Fount
//
//  Created by Rush on 6/9/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "User.h"

@interface Comment : BaseModel

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *relativeTime;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSDictionary *metadataMapsDictionary;

@property (nonatomic, assign) NSInteger mediaId;
@property (nonatomic, assign) NSInteger commentId;

@end
