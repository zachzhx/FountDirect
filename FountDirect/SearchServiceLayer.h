//
//  SearchServiceLayer.h
//  Fount
//
//  Created by Rush on 1/6/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchServiceLayer : NSObject

typedef void(^receivedDictionary)(NSDictionary *dictionary);
typedef void(^receivedArray)(NSArray *array);
typedef void(^returnedInteger)(NSInteger number);

#pragma mark - Auto Complete Suggest
/**
 *  Gets autocompleted search result for products
 *  param keyword - word searched
 *  returns - Returns an array of search queries
 */
+(void) suggestProductWithKeyword:(NSString *) keyword completion:(receivedArray) completionBlock;

/**
 *  Gets autocompleted search result
 *  param keyword - word searched
 *  param entityType - String entity (eg - USER, BRAND, SELLER).
 *  returns - Returns an array of Users, Brands, or Sellers depending on entityType
 */
+(void) autocompleteSuggestKeyword:(NSString *) keyword entityType:(NSString *) entityType completion:(receivedArray) completionBlock;

/**
 *  Gets users based on keyword
 *  param keyword - word searched
 *  pageNumber - PageNumber starts at 1
 *  returns - Returns an array of Users
 */
+(void) searchUsersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets brands based on keyword
 *  param keyword - word searched
 *  pageNumber - PageNumber starts at 1
 *  returns - Returns an array of Brands
 */
+(void) searchBrandsWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets sellers based on keyword
 *  param keyword - word searched
 *  pageNumber - PageNumber starts at 1
 *  returns - Returns an array of Sellers
 */
+(void) searchSellersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets users based on keyword
 *  param keyword - word searched
 *  pageNumber - PageNumber starts at 1
 *  returns - Returns an array of Users
 */
+(void) suggestFollowersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

+(void) getIdForName:(NSString *) name entityType:(NSString *) entityType completion:(returnedInteger) completionBlock;

+(void) suggestHashTag:(NSString *) hashTag completion:(receivedArray) completionBlock;

@end
