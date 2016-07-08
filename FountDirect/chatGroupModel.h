//
//  chatGroupModel.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "chatUser.h"

@class chatUser;

@interface chatGroupModel : BaseModel

@property (nonatomic, strong) chatUser *owner;

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *names;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSMutableArray *usersMutableArray;

@end
