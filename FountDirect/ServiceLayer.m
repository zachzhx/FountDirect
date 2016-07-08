//
//  ServiceLayer.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/28/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ServiceLayer.h"
#import <AFNetworking/AFNetworking.h>
#import "Constants.h"
#import <Crashlytics/Crashlytics.h>
#import <Google/Analytics.h>
#import "SingleChatModel.h"

@implementation ServiceLayer

-(NSInteger) getUserId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserIdKey];
}

-(void) loginWithEmail:(NSString *) email password:(NSString *) password completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"email": email, @"password": password};
    
    //    NSLog(@"LOGIN PARAMETERS:%@", parameters);
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShouldDisplayBannerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/login", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"loginWithEmail Response:%@", responseObject);
        
        //        NSLog(@"loginWithEmail RESPONSE:%@", task.response);
        
        //        NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
        
        //        if (!errorDictionary) {
        //            [self saveUserInfo:responseObject];
        //        }
        
        if (completionBlock) {
            
            //            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSessionKey];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
            
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"loginWithEmail FAIL ERROR:%@", [error localizedDescription]);
    }];
}

- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey]];
    [CrashlyticsKit setUserEmail:[[NSUserDefaults standardUserDefaults] objectForKey:kEmailKey]];
    [CrashlyticsKit setUserName:[[NSUserDefaults standardUserDefaults] objectForKey:kDisplayNameKey]];
}

-(void) logout:(void (^)(void))completionBlock {
    NSDictionary *parameters = @{@"user.id": @([self getUserId])};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/logout", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
            NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        //        NSLog(@"Cookiejar:%@", cookieJar);
        
        for (NSHTTPCookie *cookie in [cookieJar cookies]) {
                if ([cookie.name isEqualToString:@"PLAY_SESSION"] || [cookie.domain isEqualToString:@"www.instagram.com"] || [cookie.domain isEqualToString:@".instagram.com"]) {
                //                NSLog(@"NAME:%@", cookie.name);
                [cookieJar deleteCookie:cookie];
            }
            
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDisplayNameKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEmailKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstagramProfilePictureStringKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIdKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfItemsInCartKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfirmedKey];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSessionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        if (completionBlock) {
            completionBlock();
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"Logout TIME OUT ERROR");
        }
        
        NSLog(@"Logout FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Push Notifications
-(void) updateDeviceTokenWithCompletionBlock:(receivedDictionary) completionBlock {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenKey];
    
    //Make sure deviceToken is not nil
    if (deviceToken) {
        NSDictionary *parameters = @{@"userId": @([self getUserId]), @"deviceToken": deviceToken};
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager POST:[NSString stringWithFormat:@"%@/user/updatedevicetoken", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            //            NSLog(@"updateDeviceTokenWithCompletionBlock Response:%@", responseObject);
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            //            NSLog(@"updateDeviceTokenWithCompletionBlock REPSONSE DICT:%@", dict);
            
            if (completionBlock) {
                completionBlock(dict);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"updateDeviceTokenWithCompletionBlock FAIL ERROR:%@", [error localizedDescription]);
        }];
    }
}

-(void)postForgotPasswordwithEmail:(NSString*)email completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"email": email};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/forgot/password", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postForgotPasswordwithEmail FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getCartProducts:(receivedArray) completionBlock {
    //    NSDictionary *parameters = @{@"userId": @([self getUserId]), @"twoTapForceSync": @YES};
    
    NSDictionary *parameters = @{@"twoTapForceSync": @YES};
    
    //    NSLog(@"getCartProducts parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/cart/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getCartProducts responsObject:%@", responseObject);
        
        NSArray *productsArray = [[[responseObject objectForKey:@"payload"] objectForKey:@"SHOPPING_CART"] objectForKey:@"cartProducts"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:productsArray.count forKey:kNumberOfItemsInCartKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (completionBlock) {
            completionBlock(productsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"Get Cart TIME OUT ERROR");
        }
        
        NSLog(@"Get Cart FAIL ERROR:%@", [error localizedDescription]);
        //        NSLog(@"Get Cart FAIL ERROR:%@", error);
    }];
}

-(void) getShoppingCartProductsWithUserId:(NSString *) userId twoTapForceSync:(BOOL)twoTapForce completion:(receivedDictionary) completionBlock
{
    NSDictionary *parameters = @{@"userId":userId,@"twoTapForceSync": @(twoTapForce)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/cart/get", WEB_DOMAIN ] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        
        //         NSLog(@"getShoppingCartProductsWithUserId responseObject = %@", responseObject);
        
        NSDictionary *cartProductDict = [[responseObject objectForKey:@"payload"] objectForKey:@"SHOPPING_CART"];
        
        
        if (completionBlock){
            completionBlock(cartProductDict);
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getShoppingCartProductsWithUserId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) postDelectWithShoppingCartId:(NSString *)shoppingCartId cartProductId:(NSString *)cartProductId productMetaDataId:(NSInteger) productMetaDataId completion:(receivedDictionary) completionBlock {
    
    //    NSDictionary *parameters = @{@"shoppingCart[id]":shoppingCartId, @"cartProduct[id]":cartProductId};
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    if (shoppingCartId) {
        [parameters setObject:shoppingCartId forKey:@"shoppingCart[id]"];
    }
    
    if (cartProductId) {
        [parameters setObject:cartProductId forKey:@"cartProduct[id]"];
    }
    
    if (productMetaDataId) {
        [parameters setObject:@(productMetaDataId) forKey:@"productMetaDataId"];
    }
    
    NSLog(@"postDelectWithShoppingCartId parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/cart/delete",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"postDelectWithShoppingCartId responseObject:%@",responseObject);
        
        NSDictionary *deletedProduct = [responseObject valueForKeyPath:@"payload.SHOPPING_CART_PRODUCT"];
        
        if (deletedProduct) {
            NSInteger numberOfItemsInCart = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
            numberOfItemsInCart--;
            [[NSUserDefaults standardUserDefaults] setInteger:numberOfItemsInCart forKey:kNumberOfItemsInCartKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(completionBlock){
                completionBlock(responseObject);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) postSaveForLaterwithProductId:(NSString *)cartProductId completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"cartProduct[id]":cartProductId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/cart/saveforlater",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        //        NSLog(@"postSaveForLaterwithProductId responseObject:%@",responseObject);
        
        int keyNumber = (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
        keyNumber--;
        [[NSUserDefaults standardUserDefaults] setInteger:keyNumber forKey:kNumberOfItemsInCartKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(completionBlock){
            completionBlock(responseObject);
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

+(void) googleTrackEventWithCategory:(NSString *) category actionName:(NSString *) actionName label:(NSString *) label value:(NSInteger) value {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category                   // Event category (required)
                                                          action:actionName                 // Event action (required)
                                                           label:label                      // Event label
                                                           value:@1] build]];
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
        
        NSArray *conversationSessionsArray = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_GROUP_MESSAGES"];
        
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

-(void)postConversationMessageWithChatGroupId:(NSInteger)groupId messageType:(NSString *)messageType messageContent:(NSString *)messageConent completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"chatGroupID":@(groupId), @"type":messageType, @"text":messageConent};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/dm/chat/message/post", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [[responseObject objectForKey:@"payload"] objectForKey:@"DM_CHAT_MESSAGE"];
        
        if (completionBlock){
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postConversationMessageWithChatGroupId TIME OUT ERROR");
        }
        
        NSLog(@"postConversationMessageWithChatGroupId FAIL ERROR:%@", [error localizedDescription]);
    }];
}


@end
