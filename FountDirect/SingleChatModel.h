//
//  SingleChatModel.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "chatUser.h"
#import "chatGroupModel.h"

@class chatUser;
@class chatGroupModel;

@interface SingleChatModel : BaseModel

@property (nonatomic, strong) chatUser *fromUser;
@property (nonatomic, strong) chatGroupModel *chatGroupModel;

@property (nonatomic, assign) NSInteger groupid;
@property (nonatomic, strong) NSString *timePassed;
@property (nonatomic, assign) BOOL messageIsVisible;
@property (nonatomic, strong) NSString *messageTextContent;
@property (nonatomic, strong) NSString *messageTimePassed;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, assign) NSInteger numOfUnreadMsgInGroup;


@end
