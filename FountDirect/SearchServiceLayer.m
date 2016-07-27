//
//  SearchServiceLayer.m
//  Fount
//
//  Created by Rush on 1/6/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "SearchServiceLayer.h"
#import <AFNetworking.h>
#import "Constants.h"
#import "User.h"
#import "Brand.h"
#import "Seller.h"
#import "Hashtag.h"

@implementation SearchServiceLayer

#pragma mark - Auto Complete Suggest
+(void) suggestProductWithKeyword:(NSString *) keyword completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"suggestRequest" : keyword};
    
    //    NSLog(@"autocompleteSuggestKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/search/suggest/product", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSLog(@"suggestProductKeyword ResponseObject:%@", responseObject);
        
        NSMutableArray *arrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
//        if ([entityType isEqualToString:@"USER"]) {
//            NSArray *usersArray = [responseObject valueForKeyPath:@"payload.USER"];
//            
//            for (NSDictionary *userDictionary in usersArray) {
//                User *user = [[User alloc] initWithDictionary:userDictionary];
//                
//                [arrayToReturn addObject:user];
//            }
//            
//        } else if ([entityType isEqualToString:@"BRAND"]) {
//            NSArray *brandsArray = [responseObject valueForKeyPath:@"payload.BRAND"];
//            
//            for (NSDictionary *brandDictionary in brandsArray) {
//                Brand *brand = [[Brand alloc] initWithDictionary:brandDictionary];
//                
//                [arrayToReturn addObject:brand];
//            }
//        } else if ([entityType isEqualToString:@"SELLER"]) {
//            NSArray *sellersArray = [responseObject valueForKeyPath:@"payload.SELLER"];
//            
//            for (NSDictionary *sellerDictionary in sellersArray) {
//                Seller *seller = [[Seller alloc] initWithDictionary:sellerDictionary];
//                
//                [arrayToReturn addObject:seller];
//            }
//        }
        
        if (completionBlock) {
            completionBlock(arrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"suggestProductKeyword TIME OUT ERROR");
        }
        
        NSLog(@"suggestProductKeyword ERROR:%@", [error localizedDescription]);
    }];
}

+(void) autocompleteSuggestKeyword:(NSString *) keyword entityType:(NSString *) entityType completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"entityType" : entityType, @"suggestRequest" : keyword};
    
    //    NSLog(@"autocompleteSuggestKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/search/suggest", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"autocompleteSuggestKeyword ResponseObject:%@", responseObject);
        
        NSMutableArray *arrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        if ([entityType isEqualToString:@"USER"]) {
            NSArray *usersArray = [responseObject valueForKeyPath:@"payload.USER"];
            
            for (NSDictionary *userDictionary in usersArray) {
                User *user = [[User alloc] initWithDictionary:userDictionary];
                
                [arrayToReturn addObject:user];
            }
            
        } else if ([entityType isEqualToString:@"BRAND"]) {
            NSArray *brandsArray = [responseObject valueForKeyPath:@"payload.BRAND"];
            
            for (NSDictionary *brandDictionary in brandsArray) {
                Brand *brand = [[Brand alloc] initWithDictionary:brandDictionary];
                
                [arrayToReturn addObject:brand];
            }
        } else if ([entityType isEqualToString:@"SELLER"]) {
            NSArray *sellersArray = [responseObject valueForKeyPath:@"payload.SELLER"];
            
            for (NSDictionary *sellerDictionary in sellersArray) {
                Seller *seller = [[Seller alloc] initWithDictionary:sellerDictionary];
                
                [arrayToReturn addObject:seller];
            }
        }
        
        if (completionBlock) {
            completionBlock(arrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"autocompleteSuggestKeyword TIME OUT ERROR");
        }
        
        NSLog(@"autocompleteSuggestKeyword ERROR:%@", [error localizedDescription]);
    }];
}

+(void) searchUsersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"pageNumber" : @(pageNumber), @"keyword" : keyword};
    
    //    NSLog(@"searchUsersWithKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/search", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"searchUsersWithKeyword ResponseObject:%@", responseObject);
        
        NSArray *usersArray = [responseObject valueForKeyPath:@"payload.USERS"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            [usersArrayToReturn addObject:user];
        }
        
        //        NSLog(@"USER ARR:%@", usersArrayToReturn);
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"searchUsersWithKeyword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) searchBrandsWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"pageNumber" : @(pageNumber), @"keyword" : keyword};
    
    //    NSLog(@"searchBrandsWithKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/brands/search", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"searchBrandsWithKeyword ResponseObject:%@", responseObject);
        
        NSArray *brandsArray = [responseObject valueForKeyPath:@"payload.BRANDS"];
        
        NSMutableArray *brandsArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
        
        for (NSDictionary *userDictionary in brandsArray) {
            Brand *brand = [[Brand alloc] initWithDictionary:userDictionary];
            
            [brandsArrayToReturn addObject:brand];
        }
        
        //        NSLog(@"USER ARR:%@", usersArrayToReturn);
        
        if (completionBlock) {
            completionBlock(brandsArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"searchBrandsWithKeyword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) searchSellersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"pageNumber" : @(pageNumber), @"keyword" : keyword};
    
    //    NSLog(@"searchSellersWithKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/sellers/search", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSLog(@"searchSellersWithKeyword ResponseObject:%@", responseObject);
        
        NSArray *sellersArray = [responseObject valueForKeyPath:@"payload.SELLERS"];
        
        NSMutableArray *arrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
        
        for (NSDictionary *userDictionary in sellersArray) {
            Seller *seller = [[Seller alloc] initWithDictionary:userDictionary];
            
            [arrayToReturn addObject:seller];
        }
        
        //        NSLog(@"USER ARR:%@", usersArrayToReturn);
        
        if (completionBlock) {
            completionBlock(arrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"searchSellersWithKeyword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) suggestFollowersWithKeyword:(NSString *) keyword pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    
    NSDictionary *parameters = @{@"pageNumber" : @(pageNumber), @"suggestRequest" : keyword};
    
    NSLog(@"suggestFollowersWithKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/search/suggest/innetwork", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

//        NSLog(@"suggestFollowersWithKeyword ResponseObject:%@", responseObject);
        
        NSArray *usersArray = [responseObject valueForKeyPath:@"payload.USER"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            [usersArrayToReturn addObject:user];
        }
        
        //        NSLog(@"USER ARR:%@", usersArrayToReturn);
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"suggestFollowersWithKeyword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) getIdForName:(NSString *) name entityType:(NSString *) entityType completion:(returnedInteger) completionBlock {
    
    NSDictionary *parameters = @{@"name" : name, @"fountEntityType" : entityType};
    
//    NSLog(@"getIdForName Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/search/idbyname", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSLog(@"getIdForName ResponseObject:%@", responseObject);
        
        NSInteger integerToReturn = [[responseObject valueForKeyPath:@"payload.FOUNT_ENTITY.id"] integerValue];
        
        if (completionBlock) {
            completionBlock(integerToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"getIdForName FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) suggestHashTag:(NSString *) hashTag completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"suggestRequest" : hashTag};
    
    //    NSLog(@"suggestHashTag Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/search/suggest/hashtag", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSLog(@"suggestHashTag ResponseObject:%@", responseObject);
        
        NSArray *hashtagDictionaryArray = [responseObject valueForKeyPath:@"payload.HASHTAG"];
        
        NSMutableArray *hashtagArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSDictionary *hashtagDictionary in hashtagDictionaryArray) {
            
            Hashtag *hashtag = [[Hashtag alloc] initWithSingleHashtagDictionary:hashtagDictionary];
            
            [hashtagArray addObject:hashtag];
        }
        
        if (completionBlock) {
            completionBlock(hashtagArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"suggestHashTag TIME OUT ERROR");
        }
        
        NSLog(@"suggestHashTag ERROR:%@", [error localizedDescription]);
    }];
}

@end
