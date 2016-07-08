//
//  ServiceLayer.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/28/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^receivedDictionary)(NSDictionary *dictionary);
typedef void(^receivedArray)(NSArray *array);

@interface ServiceLayer : NSObject

//getUserId
-(NSInteger) getUserId;

/**
 *  Logs in
 *  @param password: User's password
 *  @param username: User's username
 *  @return passes user object upon successful login, error object otherwise
 */
-(void) loginWithEmail:(NSString *) email password:(NSString *) password completion:(receivedDictionary) completionBlock;

/**
 Logs out
 */
-(void) logout:(void(^)(void)) completionBlock;

#pragma mark - Push Notifications
/**
 *  Updates device token
 */
-(void) updateDeviceTokenWithCompletionBlock:(receivedDictionary) completionBlock;

-(void)postForgotPasswordwithEmail:(NSString*)email completion:(receivedDictionary)completionBlock;

-(void) getCartProducts:(receivedArray) completionBlock;

-(void) getShoppingCartProductsWithUserId:(NSString *) userId twoTapForceSync:(BOOL)twoTapForce completion:(receivedDictionary) completionBlock;

-(void) postDelectWithShoppingCartId:(NSString *)shoppingCartId cartProductId:(NSString *)cartProductId productMetaDataId:(NSInteger) productMetaDataId completion:(receivedDictionary) completionBlock;

-(void) postSaveForLaterwithProductId:(NSString *)cartProductId completion:(receivedDictionary) completionBlock;

#pragma mark - Google Analytics
/**
 *  Adds an event to Google Analytics
 *  param category - *Required* Category that appears in Google Analytics
 *  param actionName - *Required* Name to describe the action user took
 *  param label - Further label to distinguish events
 *  param value - number of times event called (Usually 1)
 */
+(void) googleTrackEventWithCategory:(NSString *) category actionName:(NSString *) actionName label:(NSString *) label value:(NSInteger) value;

-(void)getChatMessageListWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void)getConversationWithGroupId:(NSInteger) groupId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void)postConversationMessageWithChatGroupId:(NSInteger)groupId messageType:(NSString *)messageType messageContent:(NSString *)messageConent completion:(receivedDictionary) completionBlock;

@end
