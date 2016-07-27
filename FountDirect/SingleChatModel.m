//
//  SingleChatModel.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "SingleChatModel.h"

@implementation SingleChatModel

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        
        NSDictionary *fromUserDict = [dictionary objectForKey:@"fromUser"];
        if(fromUserDict){
            self.fromUser = [[chatUser alloc]initWithDictionary:fromUserDict];
        }
        
        NSDictionary *chatGroupDict = [dictionary objectForKey:@"chatGroup"];
        if(chatGroupDict){
            self.chatGroupModel = [[chatGroupModel alloc]initWithDictionary:chatGroupDict];
        }
        
        self.groupid = [[dictionary objectForKey:@"id"]integerValue];
        self.timePassed = [dictionary objectForKey:@"timePassed"];
        self.messageIsVisible = [[[dictionary objectForKey:@"message"]objectForKey:@"isVisible"]boolValue];
        self.messageType = [dictionary valueForKeyPath:@"message.type"];
        self.messageTextContent = [dictionary valueForKeyPath:@"message.textContent"];
        self.messageTimePassed = [dictionary valueForKeyPath:@"message.timePassed"];
        self.numOfUnreadMsgInGroup = [[dictionary valueForKeyPath:@"numOfUnreadMsgInGroup"]integerValue];
        
    }
    return self;
}



@end
