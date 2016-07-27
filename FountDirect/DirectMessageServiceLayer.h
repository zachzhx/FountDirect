//
//  DirectMessageServiceLayer.h
//  Fount
//
//  Created by Zhang Xu on 7/6/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirectMessageServiceLayer : NSObject

typedef void(^receivedDictionary)(NSDictionary *dictionary);

typedef void(^receivedArray)(NSArray *array);

-(void)getDMFollowersWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void)postCreateDMChatGroupWithUserIdsAndGroupTypeDictionary:(NSDictionary *)dictionary completion:(receivedDictionary) completionBlock;

//-(void)postDMChatMessageWithChatGroupId:(NSInteger)chatGroupID messageType:(NSString *)messageType textMessage:(NSString *)textMessage mediaId:(NSInteger)mediaId completion:(receivedDictionary) completionBlock;

-(void)postDMChatMessageWithChatDictionary:(NSDictionary *)dictionary completion:(receivedDictionary) completionBlock;

-(void)getChatMessageListWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void)getConversationWithGroupId:(NSInteger) groupId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

//Push-Notification Get Chat Message with Reference Id
-(void)getChatMessageWithReferenceId:(NSInteger) referenceId completion:(receivedDictionary)completionBlock;

//Push-Notification Get Number Of Groups With Unread messages
-(void)getChatUnreadMessages:(receivedDictionary)completionBlock;

@end
