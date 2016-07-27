//
//  DirectMessageServiceLayer.m
//  Fount
//
//  Created by Zhang Xu on 7/6/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "DirectMessageServiceLayer.h"
#import <AFNetworking/AFNetworking.h>
#import "constants.h"

@implementation DirectMessageServiceLayer

-(void)getDMFollowersWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock{
    
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/dm/chat/user/follower/get",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSArray *array = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_USER_FOLLOWERS"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getDMFollowersWithPageNumber TIME OUT ERROR");
        }
        NSLog(@"getDMFollowersWithPageNumber ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postCreateDMChatGroupWithUserIdsAndGroupTypeDictionary:(NSDictionary *)dictionary completion:(receivedDictionary) completionBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@/dm/chat/group/create",WEB_DOMAIN] parameters:dictionary success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary *dict = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_GROUP"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postCreateDMChatGroupWithUserIdsAndGroupTypeDictionary TIME OUT ERROR");
        }
        NSLog(@"postCreateDMChatGroupWithUserIdsAndGroupTypeDictionary ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postDMChatMessageWithChatDictionary:(NSDictionary *)dictionary completion:(receivedDictionary) completionBlock{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@/dm/chat/message/post", WEB_DOMAIN] parameters:dictionary success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_MESSAGE"];
        
        if (completionBlock){
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postDMChatMessageWithChatDictionary TIME OUT ERROR");
        }
        NSLog(@"postDMChatMessageWithChatDictionary FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getChatMessageListWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock{
    
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/dm/chat/message/sessions/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *chatSessionsArray = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_SESSIONS"];
        
        if (completionBlock) {
            completionBlock(chatSessionsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getChatMessageListWithPageNumber TIME OUT ERROR");
        }
        
        NSLog(@"getChatMessageListWithPageNumber FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getConversationWithGroupId:(NSInteger) groupId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock{
    
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber), @"groupID":@(groupId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/dm/chat/group/messages/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *conversationSessionsArray = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(conversationSessionsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getConversationWithGroupId TIME OUT ERROR");
        }
        
        NSLog(@"getConversationWithGroupId FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getChatMessageWithReferenceId:(NSInteger) referenceId completion:(receivedDictionary)completionBlock{
    
    NSDictionary *parameters = @{@"chatReferenceID":@(referenceId)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/dm/chat/messages/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *messageDictionary = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_MESSAGE"];
        
        if (completionBlock) {
            completionBlock(messageDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getChatMessageWithReferenceId TIME OUT ERROR");
        }
        
        NSLog(@"getChatMessageWithReferenceId FAIL ERROR:%@", [error localizedDescription]);
    }];

}

-(void)getChatUnreadMessages:(receivedDictionary)completionBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/dm/chat/group/unread/message/get", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *unreadMsgDictionary = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(unreadMsgDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getChatUnreadMessages TIME OUT ERROR");
        }
        
        NSLog(@"getChatUnreadMessages FAIL ERROR:%@", [error localizedDescription]);
    }];

}


@end
