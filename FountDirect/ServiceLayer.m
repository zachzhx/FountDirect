//
//  ServiceLayer.m
//  On Demand Concierge
//
//  Created by Rush on 5/26/15.
//  Copyright (c) 2015 Sears. All rights reserved.
//

#import "ServiceLayer.h"
#import "Constants.h"
#import "Media.h"
#import <AFNetworking/AFNetworking.h>
#import "Product.h"
#import "VisualTag.h"
#import "ProductDetail.h"
#import "User.h"
#import "Seller.h"
#import "Address.h"
#import "VisualTag.h"
#import "Activity.h"
#import <Google/Analytics.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Notification.h"

@implementation ServiceLayer

-(void) registerWithEmail:(NSString *) email password:(NSString *) password username:(NSString *) username completion:(void(^)(void)) completionBlock {
    
    NSDictionary *parameters = @{@"email": email, @"password": password, @"displayName": username, @"termsOfUse": @YES};
    
    [self registerUserWithParameters:parameters completion:^{
        completionBlock();
    }];
}

-(void) registerViaInstagramWithEmail:(NSString *) email password:(NSString *) password username:(NSString *) username instagramId:(NSInteger) instagramId completion:(void(^)(void)) completionBlock {
    
    NSDictionary *parameters = @{@"email": email, @"password": password, @"displayName": username, @"termsOfUse": @YES, @"instagramUserId": @(instagramId)};
    
    [self registerUserWithParameters:parameters completion:^{
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void) registerUserWithParameters:(NSDictionary *) parameters completion:(void(^)(void)) completionBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/register", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"registerUserWithParameters response:%@", responseObject);
        
        if ([responseObject objectForKey:@"error"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[responseObject objectForKey:@"error"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[responseObject valueForKeyPath:@"payload.MESSAGE"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            //            [alert show];
            //            [self saveUserInfo:responseObject];
            
            if (completionBlock) {
                completionBlock();
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Register FAIL ERROR:%@", [error localizedDescription]);
    }];
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

-(void) loginViaInstagram:(int) userId completion:(void(^)(void)) completionBlock {
    
    NSDictionary *parameters = @{@"id": @(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/getUser", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"RESPONSE:%@", responseObject);
        
        [self saveUserInfo:responseObject];
        
        if (completionBlock) {
            completionBlock();
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Instagram Login FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) saveUserInfo:(NSDictionary *) responseObject {
    NSString *displayName = [[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"displayName"];
    [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:kDisplayNameKey];
    
    NSString *email = [[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kEmailKey];
    
    NSString *profilePictureString = [[[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"userInstagram"] objectForKey:@"instagramProfilePicture"];
    [[NSUserDefaults standardUserDefaults] setObject:profilePictureString forKey:kInstagramProfilePictureStringKey];
    
    //Retrieve current device token and id to see if we should update the device token + user
    //    NSInteger savedUserId = [[NSUserDefaults standardUserDefaults] integerForKey:kUserIdKey];
    //    NSLog(@"savedUserInfo Response:%@", responseObject);
    
    NSInteger userId = [[[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"id"] integerValue];
    
    //    NSLog(@"NEW USER ID:%tu", userId);
    
    [[NSUserDefaults standardUserDefaults] setInteger:userId forKey:kUserIdKey];
    
    //    BOOL userIsActivated = [[responseObject valueForKeyPath:@"payload.USER.confirmRegistrationStatus"] boolValue];
    //
    //    [[NSUserDefaults standardUserDefaults] setBool:userIsActivated forKey:kConfirmedKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self logUser];
    
    //#if RELEASE
    
    //    if (savedUserId != userId) {
    [[[ServiceLayer alloc] init] updateDeviceTokenWithCompletionBlock:^(NSDictionary *dictionary) {
        //            NSLog(@"device Dict:%@", dictionary);
    }];
    //    }
    //#endif
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
    
    //    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //
    //    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
    //        //            NSLog(@"%@", cookie);
    //
    //        NSLog(@"b4 NAME:%@", cookie.name);
    //        NSLog(@"b4 NAME:%@", cookie.domain);
    //    }
    
    [manager POST:[NSString stringWithFormat:@"%@/user/logout", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Logout Response:%@", responseObject);
        //        NSLog(@"TASK%@:", task);
        
        //        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"logout responseDictionary:%@", responseDictionary);
        
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        //        NSLog(@"Cookiejar:%@", cookieJar);
        
        for (NSHTTPCookie *cookie in [cookieJar cookies]) {
            //            NSLog(@"%@", cookie);
            
            //            NSLog(@"Name B4:%@", cookie.name);
            //            NSLog(@"Domain B4:%@", cookie.domain);
            
            if ([cookie.name isEqualToString:@"PLAY_SESSION"] || [cookie.domain isEqualToString:@"www.instagram.com"] || [cookie.domain isEqualToString:@".instagram.com"]) {
                //                NSLog(@"NAME:%@", cookie.name);
                [cookieJar deleteCookie:cookie];
            }
            
            //            NSLog(@"Name AF:%@", cookie.name);
            //            NSLog(@"Domain AF:%@", cookie.domain);
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDisplayNameKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEmailKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstagramProfilePictureStringKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIdKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNumberOfItemsInCartKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfirmedKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserTypeKey];
        
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

-(void) getLatestInstagramImagesWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    
    //    NSLog(@"getLatestInstagramImagesWithPageNumber parameters :%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/media/latest", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getLatestInstagramImagesWithPageNumber responseObject:%@", responseObject);
        
        NSArray *mediasArray = [[responseObject objectForKey:@"payload"] objectForKey:@"MEDIAS"];
        
        NSArray *arrayOfMedia = [self getArrayOfMediaFromMediasArray:mediasArray];
        
        if (completionBlock) {
            completionBlock(arrayOfMedia);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getLatestInstagramImagesWithPageNumber TIME OUT ERROR");
        }
        
        NSLog(@"getLatestInstagramImagesWithPageNumber ERROR:%@", [error localizedDescription]);
    }];
}

+(void) getMediaWithMediaId:(NSInteger) mediaId completion:(receivedDictionary) completionBlock {
    //    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"GET STR:%@", [NSString stringWithFormat:@"%@/media/%tu", WEB_DOMAIN, mediaId]);
    
    [manager GET:[NSString stringWithFormat:@"%@/media/%tu", WEB_DOMAIN, mediaId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getMediaWithMediaId responseObject:%@", responseObject);
        
        Media *media = [[Media alloc] initWithDictionary:[responseObject valueForKeyPath:@"payload.MEDIA"]];
        
        NSArray *likedUsersArray = [responseObject valueForKeyPath:@"payload.LIKED_USERS"];
        
        NSDictionary *dictionaryToPass;
        
        if (likedUsersArray.count > 0) {
            dictionaryToPass = @{@"media" : media, @"likedUsers" : likedUsersArray};
        } else {
            dictionaryToPass = @{@"media" : media};
        }
        
        if (completionBlock) {
            completionBlock(dictionaryToPass);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getMediaWithMediaId TIME OUT ERROR");
        }
        
        NSLog(@"getMediaWithMediaId FAIL ERROR:%@", [error localizedDescription]);
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

-(NSInteger) getUserId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserIdKey];
}

+(NSString *) getDisplayName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDisplayNameKey];
}

-(void) likeMedia:(NSInteger) mediaId completion:(receivedDictionary) completionBlock {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Generic Media Like"
                                                          action:@"Media Like Clicked"
                                                           label:nil
                                                           value:@1] build]];
    
    NSDictionary *parameters = @{@"media[id]": @(mediaId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/social/medialike", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Like FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) unlikeMedia:(NSInteger) mediaId completion:(receivedDictionary) completionBlock {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Generic Media Unlike"
                                                          action:@"Media Unlike Clicked"
                                                           label:nil
                                                           value:@1] build]];
    
    NSDictionary *parameters = @{@"media[id]": @(mediaId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/social/mediaunlike", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unlike FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getProductTagsWithMediaId:(NSInteger) mediaId completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(mediaId)};
    
    //    NSLog(@"MEDIA ID:%tu", mediaId);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/media/get/tags", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getProductTagsWithMediaId Response:%@", responseObject);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"responseView" object:responseObject];//Zach
        
        
        NSMutableArray *tagsArrayToReturn = [[NSMutableArray alloc] init];
        
        NSArray *tagsArray = [[responseObject objectForKey:@"payload"] objectForKey:@"VISUALTAGS"];
        
        for (NSDictionary *dictionary in tagsArray) {
            VisualTag *tag = [[VisualTag alloc] initWithDictionary:dictionary];
            
            if (tag.productTagger.userId == [self getUserId]) {
                tag.isMine = YES;
            }
            
            [tagsArrayToReturn addObject:tag];
        }
        
        if (completionBlock) {
            completionBlock(tagsArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getProductTagsWithMediaId TIME OUT ERROR");
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem loading the products, please insure you have a stable internet connection and refresh the page" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            //            [alert show];
        }
        
        NSLog(@"getProductTagsWithMediaId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Product Helper Methods
//-(NSArray *) getArrayOfProductsWithProductsArray:(NSArray *) productsArray {
//    for (NSDictionary *productDictionary in productsArray) {
//        Product *product = [[Product alloc] initWithDictionary:productDictionary];
//    }
//}

-(NSArray *) getArrayOfProductsWithProductsDataArray:(NSArray *) productsArray tagId:(NSUInteger) tagId {
    NSMutableArray *productsArrayToReturn = [[NSMutableArray alloc] init];
    
    //    NSLog(@"prod:%@", productsArray);
    
    int count = 0;
    
    for (NSDictionary *productDictionary in productsArray) {
        count++;
        //        NSLog(@"P DICT:%@", productDictionary);
        
        Product *product = [[Product alloc] initWithDictionary:productDictionary];
        
        //        NSLog(@"SERVI ARR --NAME:%@ -- INS:%i", product.name, product.inStock);
        
        NSDictionary *twoTapDataDictionary = [productDictionary objectForKey:@"twoTapData"];
        
        if (twoTapDataDictionary) {
            NSDictionary *sitesDictionary = [twoTapDataDictionary objectForKey:@"sites"];
            
            NSString *key = [[sitesDictionary allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
            NSDictionary *insideSitesDict = [sitesDictionary objectForKey:key];
            NSDictionary *addToCartDictionary = [insideSitesDict objectForKey:@"add_to_cart"];
            
            if (addToCartDictionary) {
                NSString *cartKey = [[addToCartDictionary allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
                NSDictionary *insideAddToCartDictionary = [addToCartDictionary objectForKey:cartKey];
                
                NSString *originalPrice = [insideAddToCartDictionary objectForKey:@"original_price"];
                
                if (originalPrice.length > 0) {
                    NSString *newOriginalPriceString = [originalPrice substringFromIndex:1];
                    
                    CGFloat newOriginalPrice = [newOriginalPriceString floatValue];
                    
                    if (newOriginalPrice > 0) {
                        product.price = newOriginalPrice;
                    }
                }
                
                NSString *finalPrice = [insideAddToCartDictionary objectForKey:@"price"];
                NSString *newFinalPriceString = [finalPrice substringFromIndex:1];
                
                CGFloat newFinalPrice = [newFinalPriceString floatValue];
                
                if (newFinalPrice > 0) {
                    product.finalPrice = newFinalPrice;
                }
                
                if (product.finalPrice <= 0) {
                    product.finalPrice = product.price;
                }
            }
        }
        
        //        NSLog(@"COUNT XXX:%i", count);
        
        int taggerId = [[[productDictionary objectForKey:@"productTagger"] objectForKey:@"id"] intValue];
        
        if (taggerId == [self getUserId]) {
            product.isMine = YES;
        }
        
        product.visualTagId = tagId;
        
        [productsArrayToReturn addObject:product];
    }
    
    return productsArrayToReturn;
}

-(void) addTagToMediaId:(NSInteger) mediaId tagLocation:(CGPoint) tagLocation productIdArray:(NSArray *) productsArray completion:(receivedDictionary) completionBlock {
    
    NSDictionary *tag = @{
                          @"percentageX": @(tagLocation.x),
                          @"percentageY": @(tagLocation.y),
                          @"isVisible": @true
                          };
    
    NSMutableArray *productIdsArray = [[NSMutableArray alloc] init];
    
    for (Product *product in productsArray) {
        [productIdsArray addObject:@(product.productId)];
    }
    
    NSDictionary *parameters = @{
                                 @"user.id" : @([self getUserId]),
                                 @"media.id" : @(mediaId),
                                 @"visualTag" : tag,
                                 @"productIds[]" : productIdsArray
                                 };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/media/add/tag", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"addTagToMediaId response:%@", responseObject);
        
        NSDictionary *dictionary = [[responseObject objectForKey:@"payload"] objectForKey:@"VISUALTAG"];
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Add Tag to Media FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) addProductToTagId:(NSUInteger) tagId productIdArray:(NSArray *) productsArray completion:(receivedArray) completionBlock {
    
    NSDictionary *tag = @{
                          @"id": @(tagId),
                          };
    
    NSMutableArray *mutableArrayOfProductIds = [[NSMutableArray alloc] initWithCapacity:productsArray.count];
    
    for (Product *product in productsArray) {
        [mutableArrayOfProductIds addObject:@(product.productId)];
    }
    
    NSDictionary *parameters = @{
                                 @"visualTag" : tag,
                                 @"productIds" : mutableArrayOfProductIds
                                 };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/tag/add/products", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"addProductToTagId responseObj:%@", responseObject);
        
        NSArray *array = [[responseObject objectForKey:@"payload"] objectForKey:@"PRODUCTS"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Add product to tag FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) deleteTagWithTagId:(NSUInteger) tagId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"visualTag[id]": @(tagId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/media/delete/tag", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"deleteTagWithTagId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) deleteProductWithProduct:(Product *) product tag:(VisualTag *) tag completion:(receivedDictionary) completionBlock {
    //    NSDictionary *parameters = @{@"visualTag": [tag dictionary], @"product": [product dictionary]};
    
    NSDictionary *parameters = @{@"visualTag.id": @(tag.visualTagId), @"product.id": @(product.productId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/tag/delete/product", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"deleteProductWithProductId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) likeProductWithProductId:(NSUInteger) productId completion:(receivedDictionary) completionBlock {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Generic Product Like"
                                                          action:@"Product Like Clicked"
                                                           label:nil
                                                           value:@1] build]];
    
    NSDictionary *parameters = @{@"product[id]": @(productId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/product/like", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"likeProductWithProductId responseObject:%@", dict);
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unlike FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) unlikeProductWithProductId:(NSUInteger) productId completion:(receivedDictionary) completionBlock {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Generic Product Unlike"
                                                          action:@"Product unLike Clicked"
                                                           label:nil
                                                           value:@1] build]];
    
    NSDictionary *parameters = @{@"product[id]": @(productId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/product/unlike", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unlike FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) checkMediaOwnerWithMediaId:(NSInteger) mediaId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(mediaId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/media/owner", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"checkMediaOwnerWithMediaId responseObject:%@", responseObject);
        
        NSDictionary *dictionary = [[responseObject objectForKey:@"payload"] objectForKey:@"MEDIA_OWNER"];
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Check Media FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getBrandInfoWithBrandId:(NSInteger) brandId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(brandId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/brand/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getBrandInfoWithBrandId Response:%@", responseObject);
        
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        
        //        NSLog(@"getBrandInfoWithBrandId Response:%@", dict);
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getBrandInfoWithBrandId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getFilteredProductCountWithFilter:(NSString *) filterRequest completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"filterRequest": filterRequest};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/product/filter/count", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getFilteredProductCountWithFilter Response:%@", responseObject);
        
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        
        //        NSLog(@"getBrandInfoWithBrandId Response:%@", dict);
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getFilteredProductCountWithFilter FAIL ERROR:%@", [error localizedDescription]);
    }];
}

//-(void) getFilteredProductsBySortFilter:(NSString *) relevancy sellerId:(NSInteger)sellerId profileId:(NSInteger) profileId pageNumber:(NSInteger) pageNumber filterRequest:(NSString *) filterRequest completion:(receivedDictionary) completionBlock {
-(void) getFilteredProductsBySortFilter:(NSString *) relevancy userId:(NSInteger) userId pageNumber:(NSInteger) pageNumber filterRequest:(NSString *) filterRequest availabililty:(NSString *)availability completion:(receivedDictionary)completionBlock {
    
    NSDictionary *parameters;
    
    //    if (userId == [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] intValue]) {
    parameters = @{@"sortBy": relevancy, @"pageNumber": @(pageNumber), @"filterRequest": filterRequest, @"availability" : availability};
    //    }
    //    else {
    //        if (sellerId) {
    //            parameters = @{@"sellerIds[]": @(sellerId), @"sortBy": relevancy, @"pageNumber": @(pageNumber)};
    //        } else {
    //            parameters = @{@"brandIds[]": @(profileId), @"sortBy": relevancy, @"pageNumber": @(pageNumber)};
    //        }
    //    }
    
    //    NSLog(@"getFilteredProductsBySortFilter parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/product/filter", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getFilteredProductsBySortFilter responseObject:%@", responseObject);
        
        NSArray *productsArrayJson = [[responseObject objectForKey:@"payload"] objectForKey:@"PRODUCTS"];
        
        NSArray *arrayOfProducts = [self getArrayOfProductsWithProductsDataArray:productsArrayJson tagId:0];
        
        NSInteger count = [[responseObject valueForKeyPath:@"payload.COUNT"] integerValue];
        
        NSDictionary *dictionaryToReturn = @{@"COUNT" : @(count), @"PRODUCTS" : arrayOfProducts};
        
        //        NSLog(@"getFilteredProductsBySortFilter Response:%@", arrayOfProducts);
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getFilteredProductsBySortFilter FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getFilteredProductsBySortFilter:(NSString *) sortByFilter userId:(NSInteger) userId pageNumber:(NSInteger) pageNumber filterRequest:(NSString *) filterRequest availabililty:(NSString *) availability version:(NSString *) version completion:(receivedDictionary) completionBlock {
    
    NSDictionary *parameters;
    
    //    if (userId == [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] intValue]) {
    parameters = @{@"sortBy": sortByFilter, @"pageNumber": @(pageNumber), @"filterRequest": filterRequest, @"version" : version, @"id" : @(userId), @"availability" : availability};
    //    }
    //    else {
    //        if (sellerId) {
    //            parameters = @{@"sellerIds[]": @(sellerId), @"sortBy": relevancy, @"pageNumber": @(pageNumber)};
    //        } else {
    //            parameters = @{@"brandIds[]": @(profileId), @"sortBy": relevancy, @"pageNumber": @(pageNumber)};
    //        }
    //    }
    
    //    NSLog(@"getFilteredProductsBySortFilter parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/product/filter", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getFilteredProductsBySortFilter responseObject:%@", responseObject);
        
        NSArray *productsArrayJson = [[responseObject objectForKey:@"payload"] objectForKey:@"PRODUCTS"];
        
        NSArray *arrayOfProducts = [self getArrayOfProductsWithProductsDataArray:productsArrayJson tagId:0];
        
        NSInteger count = [[responseObject valueForKeyPath:@"payload.COUNT"] integerValue];
        
        NSDictionary *dictionaryToReturn = @{@"COUNT" : @(count), @"PRODUCTS" : arrayOfProducts};
        
        //        NSLog(@"getFilteredProductsBySortFilter Response:%@", arrayOfProducts);
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getFilteredProductsBySortFilter FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getUserInformationWithUserId:(NSInteger)userId completion:(receivedDictionary)completionBlock {
    NSDictionary *parameters = @{@"id": @(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/get/publicprofile", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"User Info Response:%@", responseObject);
        
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        
        //        NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
        //
        //        if (!errorDictionary) {
        //            [self saveUserInfo:responseObject];
        //        }
        //
        //        if (completionBlock) {
        //
        //            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSessionKey];
        //            [[NSUserDefaults standardUserDefaults] synchronize];
        //
        //            completionBlock(responseObject);
        //        }
        
        //        NSLog(@"User Info Response:%@", dict);
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"User Info FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Get Posts
-(void) getUserPostsWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    
    NSDictionary *parameters = @{@"userId": @(userId), @"pageNumber": @(pageNumber)};
    
    //    NSLog(@"getUserPostsWithUserId parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/get/media", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"getUserPostsWithUserId Dict:%@", dict);
        
        NSArray *mediasArray = [[dict objectForKey:@"payload"] objectForKey:@"MEDIAS"];
        
        NSArray *arrayOfMedia = [self getArrayOfMediaFromMediasArray:mediasArray];
        
        if (completionBlock) {
            completionBlock(arrayOfMedia);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getUserPostsWithUserId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getBrandPostsWithBrandId:(NSInteger) brandId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(brandId), @"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"getBrandPostsWithBrandId parameters:%@", parameters);
    
    [manager GET:[NSString stringWithFormat:@"%@/brand/posts", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getBrandPostsWithBrandId Response:%@", responseObject);
        
        NSArray *mediasArray = [[responseObject objectForKey:@"payload"] objectForKey:@"BRAND_POSTS"];
        
        NSArray *arrayOfMedia = [self getArrayOfMediaFromMediasArray:mediasArray];
        
        if (completionBlock) {
            completionBlock(arrayOfMedia);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getBrandPostsWithBrandId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

//-(void) getFollowersWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
//    NSDictionary *parameters = @{@"id": @(userId), @"pageNumber": @(pageNumber)};
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager GET:[NSString stringWithFormat:@"%@/user/followsme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//
////        NSLog(@"Followers Response:%@", responseObject);
//
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//
//        NSLog(@"Followers Response:%@", dict);
//
//        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
//        NSArray *usersArray = [[dict objectForKey:@"payload"] objectForKey:@"USERS"];
//
//        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
//
////        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
//
//        for (NSDictionary *userDictionary in usersArray) {
//            User *user = [[User alloc] initWithDictionary:userDictionary];
//
//            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
//
//                NSInteger followingId = [[usersDict objectForKey:@"userId"] integerValue];
//
////                if (user.userId == followingId) {
////                    user.following = YES;
////                }
//
//                user.following = [[usersDict objectForKey:@"follow"] boolValue];
//                user.isPendingApproval = [[usersDict objectForKey:@"isApprovalPending"] boolValue];
//            }
//
//            [usersArrayToReturn addObject:user];
//        }
//
//        if (completionBlock) {
//            completionBlock(usersArrayToReturn);
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"Followers FAIL ERROR:%@", [error localizedDescription]);
//    }];
//}

-(void) getFollowersWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(userId), @"pageNumber": @(pageNumber), @"version" : version};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/followsme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Followers Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"Followers Response:%@", dict);
        
        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
        NSArray *usersArray = [[dict objectForKey:@"payload"] objectForKey:@"USERS"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersCurrentUserIsFollowingArray);
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
                
                NSInteger followingId = [[usersDict objectForKey:@"userId"] integerValue];
                
                if (user.userId == followingId) {
                    //                    user.following = YES;
                    user.following = [[usersDict objectForKey:@"follow"] boolValue];
                    user.isPendingApproval = [[usersDict objectForKey:@"isApprovalPending"] boolValue];
                }
            }
            
            [usersArrayToReturn addObject:user];
        }
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Followers FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getFollowersWithBrandId:(NSInteger) brandId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(brandId), @"pageNumber": @(pageNumber), @"version" : version};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/brand/followers", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Brand Followers Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"Brand Followers Response:%@", dict);
        
        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
        NSArray *usersArray = [[dict objectForKey:@"payload"] objectForKey:@"USERS"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        //        NSLog(@"USERS ARR:%@", usersArray);
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
                int followingId = [[usersDict objectForKey:@"userId"] intValue];
                
                if (user.userId == followingId) {
                    //                    user.following = YES;
                    user.following = [[usersDict objectForKey:@"follow"] boolValue];
                    user.isPendingApproval = [[usersDict objectForKey:@"isApprovalPending"] boolValue];
                }
            }
            
            [usersArrayToReturn addObject:user];
        }
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Brand Followers FAIL ERROR:%@", [error localizedDescription]);
    }];
}

//-(void) getUsersAndBrandsImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
//    NSDictionary *parameters = @{@"id": @(userId), @"pageNumber": @(pageNumber)};
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//
////    NSLog(@"getUsersAndBrandsImFollowing parameters:%@", parameters);
//
//    [manager GET:[NSString stringWithFormat:@"%@/user/followedbyme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//
////        NSLog(@"getUsersAndBrandsImFollowing responseObject:%@", responseObject);
//
////        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
//        NSArray *usersCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
//        NSArray *usersArray = [[responseObject objectForKey:@"payload"] objectForKey:@"USERS"];
//
//        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
//
//        for (NSDictionary *userDictionary in usersArray) {
//            User *user = [[User alloc] initWithDictionary:userDictionary];
//            user.isABrand = NO;
//
//            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
//                int followingId = [[usersDict objectForKey:@"userId"] intValue];
//
//                if (user.userId == followingId) {
//                    user.following = YES;
//                }
//            }
//            [usersArrayToReturn addObject:user];
//        }
//
//        NSArray *brandsCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"BRAND_SOCIAL_ACTION"];
//        NSArray *brandsArray = [[responseObject objectForKey:@"payload"] objectForKey:@"BRAND"];
//
//        for (NSDictionary *brandDictionary in brandsArray) {
//            User *user = [[User alloc] init];
//            user.displayName = [brandDictionary objectForKey:@"name"];
//            int brandId = [[brandDictionary objectForKey:@"id"] intValue];
//            user.isABrand = YES;
//            user.userId = brandId;
////            user.imageURL = [brandDictionary objectForKey:@"imageUrl"];
//            user.imageURL = [brandDictionary objectForKey:@"localImageUrl"];
//
//            for (NSDictionary *brandsDict in brandsCurrentUserIsFollowingArray) {
//                int followingId = [[brandsDict objectForKey:@"brandId"] intValue];
//
//                if (brandId == followingId) {
//
//                    user.following = YES;
//                }
//            }
//            [usersArrayToReturn addObject:user];
//        }
//
//        NSArray *sellersCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"SELLER_SOCIAL_ACTION"];
//        NSArray *sellersArray = [[responseObject objectForKey:@"payload"] objectForKey:@"SELLERS"];
//
//        for (NSDictionary *sellerDictionary in sellersArray) {
//            User *user = [[User alloc] init];
//            user.displayName = [sellerDictionary objectForKey:@"name"];
//            int sellerId = [[sellerDictionary objectForKey:@"id"] intValue];
//            user.isASeller = YES;
//            user.userId = sellerId;
////            user.imageURL = [sellerDictionary objectForKey:@"imageUrl"];
//            user.imageURL = [sellerDictionary objectForKey:@"localImageUrl"];
//
//            for (NSDictionary *sellersDict in sellersCurrentUserIsFollowingArray) {
//                int followingId = [[sellersDict objectForKey:@"sellerId"] intValue];
//
//                if (sellerId == followingId) {
//
//                    user.following = YES;
//                }
//            }
//            [usersArrayToReturn addObject:user];
//        }
//
//        if (completionBlock) {
//            completionBlock(usersArrayToReturn);
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"getUsersAndBrandsImFollowing FAIL ERROR:%@", [error localizedDescription]);
//    }];
//}

-(void) getUsersAndBrandsImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(userId), @"pageNumber": @(pageNumber), @"version" : version};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"getUsersAndBrandsImFollowing parameters:%@", parameters);
    
    [manager GET:[NSString stringWithFormat:@"%@/user/followedbyme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getUsersAndBrandsImFollowing responseObject:%@", responseObject);
        
        //        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
        NSArray *usersCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
        NSArray *usersArray = [[responseObject objectForKey:@"payload"] objectForKey:@"USERS"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            user.isABrand = NO;
            
            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
                int followingId = [[usersDict objectForKey:@"userId"] intValue];
                
                if (user.userId == followingId) {
                    //                    user.following = YES;
                    user.following = [[usersDict objectForKey:@"follow"] boolValue];
                    user.isPendingApproval = [[usersDict objectForKey:@"isApprovalPending"] boolValue];
                }
            }
            [usersArrayToReturn addObject:user];
        }
        
        NSArray *brandsCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"BRAND_SOCIAL_ACTION"];
        NSArray *brandsArray = [[responseObject objectForKey:@"payload"] objectForKey:@"BRAND"];
        
        for (NSDictionary *brandDictionary in brandsArray) {
            User *user = [[User alloc] init];
            user.displayName = [brandDictionary objectForKey:@"name"];
            int brandId = [[brandDictionary objectForKey:@"id"] intValue];
            user.isABrand = YES;
            user.userId = brandId;
            //            user.imageURL = [brandDictionary objectForKey:@"imageUrl"];
            user.imageURL = [brandDictionary objectForKey:@"localImageUrl"];
            
            for (NSDictionary *brandsDict in brandsCurrentUserIsFollowingArray) {
                int followingId = [[brandsDict objectForKey:@"brandId"] intValue];
                
                if (brandId == followingId) {
                    
                    user.following = YES;
                }
            }
            [usersArrayToReturn addObject:user];
        }
        
        NSArray *sellersCurrentUserIsFollowingArray = [[responseObject objectForKey:@"payload"] objectForKey:@"SELLER_SOCIAL_ACTION"];
        NSArray *sellersArray = [[responseObject objectForKey:@"payload"] objectForKey:@"SELLERS"];
        
        for (NSDictionary *sellerDictionary in sellersArray) {
            User *user = [[User alloc] init];
            user.displayName = [sellerDictionary objectForKey:@"name"];
            int sellerId = [[sellerDictionary objectForKey:@"id"] intValue];
            user.isASeller = YES;
            user.userId = sellerId;
            //            user.imageURL = [sellerDictionary objectForKey:@"imageUrl"];
            user.imageURL = [sellerDictionary objectForKey:@"localImageUrl"];
            
            for (NSDictionary *sellersDict in sellersCurrentUserIsFollowingArray) {
                int followingId = [[sellersDict objectForKey:@"sellerId"] intValue];
                
                if (sellerId == followingId) {
                    
                    user.following = YES;
                }
            }
            [usersArrayToReturn addObject:user];
        }
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getUsersAndBrandsImFollowing FAIL ERROR:%@", [error localizedDescription]);
    }];
}

//-(void) getUserLikedMediaWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
-(void) getUserLikedMediaWithPageNumber:(NSInteger) pageNumber version:(NSString *) version userId:(NSInteger) userId completion:(receivedArray) completionBlock {
    
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber), @"version" : version, @"id" : @(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"getUserLikedMediaWithPageNumber parameters:%@", parameters);
    
    [manager GET:[NSString stringWithFormat:@"%@/social/mediauserliked", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getUserLikedMediaWithPageNumber responseObject:%@", responseObject);
        
        NSArray *mediasArray = [[responseObject objectForKey:@"payload"] objectForKey:@"MEDIAS_LIKED"];
        
        NSArray *arrayOfMedia = [self getArrayOfMediaFromMediasArray:mediasArray];
        
        if (completionBlock) {
            completionBlock(arrayOfMedia);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getUserLikedMediaWithPageNumber FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Media Helper Method
-(NSArray *) getArrayOfMediaFromMediasArray:(NSArray *) mediasArray {
    
    NSMutableArray *mutableArrayOfMedia = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSDictionary *mediaDictionary in mediasArray) {
        
        Media *media = [[Media alloc] initWithDictionary:mediaDictionary];
        
        [mutableArrayOfMedia addObject:media];
    }
    
    return mutableArrayOfMedia;
}

#pragma mark - Follow Brand/User/Seller
-(void) followBrand:(NSInteger) brandId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(brandId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/brand/follow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Follow Brand Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"BRAND"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Follow Brand FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) unfollowBrand:(NSInteger) brandId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(brandId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/brand/unfollow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Unfollow Brand Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"BRAND"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unfollow Brand FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) followUser:(NSInteger) userId completion:(receivedDictionary) completionBlock {
    
    NSDictionary *parameters = @{@"id": @(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/follow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Follow User Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"USER"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Follow User FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) unfollowUser:(NSInteger) userId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/unfollow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Unfollow User Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"USER"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unfollow User FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) followSeller:(NSInteger) sellerId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(sellerId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/seller/follow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Follow Brand Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"SELLER"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Follow Seller FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) unfollowSeller:(NSInteger) sellerId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(sellerId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/seller/unfollow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [[dict objectForKey:@"payload"] objectForKey:@"SELLER"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Unfollow Seller FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getUserCommission:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @([self getUserId])};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/order/commission/outstanding", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *responseDictionary = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getUserCommission FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getUserPoints:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @([self getUserId])};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/points/available", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getUserPoints Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [dict objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(responseDictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getUserPoints FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark ProductDeatail api Call
-(void) getProductDetailsWithProductId:(NSString *) productId completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"id": productId};
    
    //    NSLog(@"parameters :%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/products/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *productDict = [[responseObject objectForKey:@"payload"] objectForKey:@"PRODUCT"];
        
        //        NSLog(@"getProductDetailsWithProductId responseObject :%@", responseObject);
        
        if (completionBlock) {
            completionBlock(productDict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark Relevent Posts api Call
-(void) getReleventPostsWithProductId:(NSString *) productId pageNumber:(NSString*)aPageNumber completion:(receivedArray) completionBlock
{
    
    //    NSLog(@"Relevant Post productId :%@",productId);
    //    NSLog(@"Relevant Post aPageNumber :%@",aPageNumber);
    
    NSDictionary *parameters = @{@"pageNumber":aPageNumber,@"id": productId};
    //    NSDictionary *parameters = @{@"pageNumber":aPageNumber,@"id": @"1571931"};
    //  NSLog(@"parameters :%@",parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/media/relevant", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //  NSLog(@"responseObject :%@",responseObject);
        NSArray *relevantPostArray = [[responseObject objectForKey:@"payload"] objectForKey:@"MEDIAS"] ;
        if (completionBlock) {
            completionBlock(relevantPostArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
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

-(void)getImportPhotosWithUserId:(NSString *)useId nextMaxId:(NSString *)nextMaxId completion:(receivedDictionary)completionBlock
{
    NSDictionary *parameters = @{@"userId":useId, @"next_max_id":nextMaxId};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/instagram/user/media",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        // NSLog(@"response :%@",responseObject);
        NSDictionary *importPhotosDict = [responseObject objectForKey:@"payload"];
        if(completionBlock){
            completionBlock(importPhotosDict);
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getImportFeedsWithUserId:(NSString *)userId nextMaxId:(NSString *)nextMaxId completion:(receivedDictionary)completionBlock
{
    NSDictionary *parameters = @{@"userId":userId, @"next_max_id":nextMaxId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/instagram/user/feed",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        // NSLog(@"responseObject :%@",responseObject);
        NSDictionary *importFeedsDict = [responseObject objectForKey:@"payload"];
        if(completionBlock){
            completionBlock(importFeedsDict);
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

#pragma mark - Checkout Flow
+(void) getCheckoutProducts:(NSArray *) arrayOfShoppingCartProductId completion:(receivedDictionary)completionBlock {
    
}

+(void) getCheckoutProducts:(NSArray *) arrayOfShoppingCartProductId sellerCouponsDictionary:(NSDictionary *) sellerCouponsDictionary  completion:(receivedDictionary) completionBlock {
    //341
    
    //selectedProductMetaDataIds ->
    
    //    NSDictionary *parameters = @{
    //                                 @"selectedProducts[]": arrayOfShoppingCartProductId
    //                                 };
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    //    NSDictionary *parameters = @{
    //                                 @"selectedProductMetaDataIds[]": arrayOfShoppingCartProductId,
    //                                 @"sellerCoupons": @{@"4": @"style"}
    //                                 };
    
    [parameters setObject:arrayOfShoppingCartProductId forKey:@"selectedProductMetaDataIds"];
    
    if (sellerCouponsDictionary.count > 0) {
        [parameters setObject:sellerCouponsDictionary forKey:@"sellerCoupons"];
    }
    
    //    NSLog(@"getCheckoutProducts parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/checkout/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getCheckoutProducts responseObject:%@", responseObject);
        
        NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
        
        if (errorDictionary) {
            
            NSDictionary *dictionaryToPass = @{@"error" : errorDictionary};
            
            if (completionBlock) {
                completionBlock(dictionaryToPass);
            }
            
        } else {
            
            NSDictionary *payload = [responseObject objectForKey:@"payload"];
            
            if (completionBlock) {
                completionBlock(payload);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getCheckoutProducts FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) addImageMedia:(NSMutableDictionary *)mediaDict completion:(receivedDictionary) completionBlock {
    [mediaDict setObject:@([self getUserId]) forKey:@"user[id]"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/add/igmedia", WEB_DOMAIN] parameters:mediaDict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"RESPONSE OBJ:%@", responseObject);
        
        if ([responseObject objectForKey:@"error"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[responseObject objectForKey:@"error"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            // Call is successful
            if (completionBlock) {
                completionBlock(responseObject);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Post Medias FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getSellersByFilter:(NSString *) filter completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"filter": filter};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/seller/shop", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSellersByFilter Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *responseDictionary = [dict objectForKey:@"payload"];
        NSArray *sellersArray = [responseDictionary objectForKey:@"SELLERS"];
        
        NSMutableArray *arrayOfSellers = [[NSMutableArray alloc] initWithCapacity:sellersArray.count];
        
        for (NSDictionary *sellerDictionary in sellersArray) {
            Seller *seller = [[Seller alloc] initWithDictionary:sellerDictionary];
            [arrayOfSellers addObject:seller];
        }
        
        if (completionBlock) {
            completionBlock(arrayOfSellers);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getSellersByFilter FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) getSellerProductsWithSellerId:(NSInteger) sellerId filter:(NSString *) filter pageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"filter": filter, @"sellerId": @(sellerId), @"pageNumber": @(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/seller/products", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSellerProductsWithSellerId Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *responseDictionary = [dict objectForKey:@"payload"];
        
        NSInteger count = [[responseDictionary objectForKey:@"COUNT"] integerValue];
        
        NSArray *productsArray = [responseDictionary objectForKey:@"PRODUCTS"];
        
        NSMutableArray *arrayOfProducts = [[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSDictionary *productDictionary in productsArray) {
            Product *product = [[Product alloc] initWithDictionary:productDictionary];
            [arrayOfProducts addObject:product];
        }
        
        NSDictionary *dictionaryToReturn = @{@"count": @(count), @"arrayOfProducts": arrayOfProducts};
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getSellerProductsWithSellerId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Shipping APIs
-(void) verifyAddressWithAddress:(Address *) address completion:(receivedDictionary) completionBlock {
    NSDictionary *dict = [address dictionary];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [parameters setObject:dict forKey:@"address"];
    
    BOOL sessionExists = [[NSUserDefaults standardUserDefaults] boolForKey:kSessionKey];
    
    if (sessionExists) {
        [parameters setObject:@([self getUserId]) forKey:@"user.id"];
    }
    
    //    NSDictionary *parameters = @{@"user.id": @([self getUserId]), @"address": dict};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/address/verify", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"verifyAddressWithAddress Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //        NSLog(@"verifyAddressWithAddress Serialized Response:%@", dict);
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionBlock) {
            completionBlock(dict);
        }
        //        NSLog(@"verifyAddressWithAddress FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) addShippingAddressWithAddress:(Address *) address completion:(void(^)(Address *address)) completionBlock {
    NSDictionary *dict = [address dictionary];
    
    NSDictionary *parameters = @{@"user.id": @([self getUserId]), @"address": dict};
    
    //    NSLog(@"addShippingAddressWithAddress Parameters:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/address/add", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //        NSLog(@"addShippingAddressWithAddress Serialized Response:%@", dict);
        
        NSDictionary *responseDictionary = [dict objectForKey:@"payload"];
        
        NSDictionary *addressDictionary = [responseDictionary objectForKey:@"ADDRESS"];
        
        Address *address = [[Address alloc] initWithDictionary:addressDictionary];
        
        if (completionBlock) {
            completionBlock(address);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"addShippingAddressWithAddress FAIL ERROR:%@", [error localizedDescription]);
    }];
}

+(void) getShippingAddressWithAddressType:(NSString *) addressType completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"addressType": addressType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/address/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getShippingAddressWithAddressType Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *responseDictionary = [dict objectForKey:@"payload"];
        
        //        NSLog(@"getShippingAddressWithAddressType Dict:%@", responseDictionary);
        
        NSArray *addressArray = [responseDictionary objectForKey:@"ADDRESSES"];
        
        NSMutableArray *arrayOfAddresses = [[NSMutableArray alloc] init];
        //
        for (NSDictionary *addressDictionary in addressArray) {
            Address *address = [[Address alloc] initWithDictionary:addressDictionary];
            [arrayOfAddresses addObject:address];
        }
        
        if (completionBlock) {
            completionBlock(arrayOfAddresses);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"receivedArray FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) purchase:(NSDictionary *) dict completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = dict;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSLog(@"purchase parameter:%@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@/checkout/purchase", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"purchase Response:%@", responseObject);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"purchase REPSONSE DICT:%@", dict);
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"purchase FAIL ERROR:%@", [error localizedDescription]);
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

-(void) postAddToCart:(NSDictionary *)productDict completion:(receivedDictionary) completionBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"postAddToCart parameters:%@", productDict);
    
    [manager POST:[NSString stringWithFormat:@"%@/cart/discover/add", WEB_DOMAIN] parameters:productDict success:^(NSURLSessionDataTask *task, id responseObject){
        //        NSLog(@"postAddToCart reponseObject:%@", responseObject);
        
        //        NSLog(@"postAddToCart response:%@", task.response);
        
        if ([responseObject objectForKey:@"error"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[responseObject objectForKey:@"error"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        } else {
            // Call is successful
            
            NSInteger keyNumber = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
            keyNumber++;
            [[NSUserDefaults standardUserDefaults] setInteger:keyNumber forKey:kNumberOfItemsInCartKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (completionBlock) {
                completionBlock(responseObject);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postAddToCart FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) postShopAddToCart:(NSDictionary *)productDict completion:(receivedDictionary) completionBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    NSLog(@"postShopAddToCart parameters:%@", productDict);
    
    [manager POST:[NSString stringWithFormat:@"%@/cart/shop/add", WEB_DOMAIN] parameters:productDict success:^(NSURLSessionDataTask *task, id responseObject){
        //        NSLog(@"postShopAddToCart responseObject:%@", responseObject);
        
        //        int keyNumber = (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
        //        keyNumber++;
        //        [[NSUserDefaults standardUserDefaults] setInteger:keyNumber forKey:kNumberOfItemsInCartKey];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([responseObject objectForKey:@"error"]) {
            //            int keyNumber = (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
            //            keyNumber--;
            //            [[NSUserDefaults standardUserDefaults] setInteger:keyNumber forKey:kNumberOfItemsInCartKey];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[responseObject objectForKey:@"error"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            // Call is successful
            
            int keyNumber = (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
            keyNumber++;
            [[NSUserDefaults standardUserDefaults] setInteger:keyNumber forKey:kNumberOfItemsInCartKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (completionBlock) {
                completionBlock(responseObject);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
}




-(void) getVisualTagId:(NSArray *)relevantPostId productId:(NSString*)productId completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"mediaId": [relevantPostId objectAtIndex:0], @"productId": productId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/product/visualtagid", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //        NSLog(@"getVisualTagId reponseObject:%@", responseObject);
        completionBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getVisualTagId FAIL ERROR:%@", [error localizedDescription]);
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

-(void) getPushnotificationWithPageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock {
    
    //    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber), @"version" : @"v1"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/pushnotification/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (responseObject != nil) {
            //            NSError *error;
            //            NSDictionary *notificationDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            
            NSLog(@"getPushnotificationWithPageNumber responseObject:%@", responseObject);
            
            NSArray *arrayOfNotificationDictionaries = [responseObject valueForKeyPath:@"payload.PUSHNOTIFICATIONS"];
            
            NSArray *arrayOfNotifications = [self getArrayOfNotifications:arrayOfNotificationDictionaries];
            
            BOOL hasMoreData = [[responseObject valueForKeyPath:@"payload.HAS_MORE_DATA"] boolValue];
            
            NSDictionary *dictionaryToPass = @{@"array": arrayOfNotifications, @"hasMoreData": @(hasMoreData)};
            
            if (completionBlock) {
                completionBlock(dictionaryToPass);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getPushNotificationWithPageNumber FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void) getActivityWithPageNumber:(NSInteger) pageNumber version:(NSString*)version completion:(receivedDictionary) completionBlock{
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber), @"version":version};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/activity/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getActivityWithPageNumber response object:%@", responseObject);
        
        NSArray *activitiesArray = [responseObject valueForKeyPath:@"payload.ACTIVITIES"];
        
        NSArray *arrayOfActivities = [self getArrayOfActivities:activitiesArray];
        
        BOOL hasMoreData = [[responseObject valueForKeyPath:@"payload.HAS_MORE_DATA"] boolValue];
        
        NSDictionary *dictionaryToPass = @{@"arrayOfActivities": arrayOfActivities, @"hasMoreData": @(hasMoreData)};
        
        if (completionBlock) {
            completionBlock(dictionaryToPass);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"getActivityWithPageNumber FAIL ERROR:%@", [error localizedDescription]);
        
    }];
}

#pragma mark - Activities Helper Methods
-(NSArray *) getArrayOfActivities:(NSArray *) activitiesArray {
    NSMutableArray *arrayOfActivities = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSDictionary *activityDictionary in activitiesArray) {
        Activity *activity = [[Activity alloc] initWithDictionary:activityDictionary];
        [arrayOfActivities addObject:activity];
    }
    return arrayOfActivities;
}

#pragma mark - Notifications Helper Methods
-(NSArray *) getArrayOfNotifications:(NSArray *) notificationDictionariesArray {
    NSMutableArray *arrayOfNotifications = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSDictionary *notificationDictionary in notificationDictionariesArray) {
        Notification *notification = [[Notification alloc] initWithDictionary:notificationDictionary];
        
        //        LIKE_POST, FOLLOW, PRODUCTS_TAGGED_IN_MEDIA, PRODUCTS_TAGGED_IN_VT, ORDER, FOLLOW_REQUEST, FOLLOW_REQUEST_ACCEPT,
        //        COMMENTED_ON_MEDIA, MENTIONED_IN_COMMENT
        
        if ([notification.notificationType isEqualToString:@"LIKE_POST"] || [notification.notificationType isEqualToString:@"FOLLOW"] || [notification.notificationType isEqualToString:@"PRODUCTS_TAGGED_IN_MEDIA"] || [notification.notificationType isEqualToString:@"PRODUCTS_TAGGED_IN_VT"] || [notification.notificationType isEqualToString:@"ORDER"] || [notification.notificationType isEqualToString:@"FOLLOW_REQUEST"] || [notification.notificationType isEqualToString:@"FOLLOW_REQUEST_ACCEPT"] || [notification.notificationType isEqualToString:@"MENTIONED_IN_COMMENT"] || [notification.notificationType isEqualToString:@"COMMENTED_ON_MEDIA"]) {
            
            if ([notification.notificationType isEqualToString:@"COMMENTED_ON_MEDIA"]) {
                //                NSLog(@"NOTIF DI:%@", notificationDictionary);
            }
            
            [arrayOfNotifications addObject:notification];
        }
    }
    return arrayOfNotifications;
}

+(void) googleTrackEventWithCategory:(NSString *) category actionName:(NSString *) actionName label:(NSString *) label value:(NSInteger) value {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category                   // Event category (required)
                                                          action:actionName                 // Event action (required)
                                                           label:label                      // Event label
                                                           value:@1] build]];
}

#pragma mark - Auto Update
+(void) getAppVersion:(receivedDictionary) completionBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/getAppVersion", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        //        NSLog(@"getAppVersion responseObject:%@", responseObject);
        
        if (completionBlock) {
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getAppVersion FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Filter Request
/**
 *  Gets aggregation
 *  param keyword - word searched
 */
-(void) getAggregationWithKeyword:(NSString *) keyword sellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *)priceRangesArray sale:(NSInteger) sale completion:(receivedDictionary) completionBlock {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (keyword) {
        [parameters setObject:keyword forKey:@"keyword"];
    }
    
    int count = 0;
    
    if (priceRangesArray.count > 0) {
        NSMutableDictionary *priceRangeToPass = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        for (NSDictionary *priceRangeDictionary in priceRangesArray) {
            [priceRangeToPass setObject:priceRangeDictionary forKey:@(count)];
            count++;
        }
        NSArray *priceRangeArray = @[priceRangeToPass];
        
        [parameters setObject:priceRangeArray forKey:@"priceRangeList"];
    }
    
    if (sale > 0) {
        [parameters setObject:@(sale) forKey:@"sale"];
    }
    
    if (sellerIds.count > 0) {
        [parameters setObject:sellerIds forKey:@"sellerIds"];
    }
    
    if (categoryIds.count > 0) {
        [parameters setObject:categoryIds forKey:@"categoryIds"];
    }
    
    if (brandIds.count > 0) {
        [parameters setObject:brandIds forKey:@"brandIds"];
    }
    
    //    if (availabi)
    //    [parameters setObject:@"IN_STOCK" forKey:@"availability"];
    
    NSLog(@"Aggregation Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/products/getaggregation", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getAggregationWithKeyword Response:%@", responseObject);
        
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //            NSLog(@"getAggregationWithKeyword REPSONSE DICT:%@", dict);
        
        if (completionBlock) {
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getAggregationWithKeyword FAIL ERROR:%@", [error localizedDescription]);
        
        NSDictionary *dict = @{@"error" : @"There was an error. Please check your connection and try again"};
        
        if (completionBlock) {
            completionBlock(dict);
        }
    }];
}

-(void) getSearchedProductsWithKeyword:(NSString *) keyword sortyBy:(NSString *) sortBy pageNumber:(NSInteger) pageNumber sellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale availability:(NSString *) availability completion:(receivedDictionary) completionBlock {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (keyword.length > 0) {
        [parameters setObject:keyword forKey:@"keyword"];
    }
    
    [parameters setObject:@(pageNumber) forKey:@"pageNumber"];
    [parameters setObject:sortBy forKey:@"sortBy"];
    
    int count = 0;
    
    //    NSLog(@"PRICE R ARR:%@", priceRangesArray);
    
    if (priceRangesArray.count > 0) {
        NSMutableDictionary *priceRangeToPass = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        for (NSDictionary *priceRangeDictionary in priceRangesArray) {
            [priceRangeToPass setObject:priceRangeDictionary forKey:@(count)];
            count++;
        }
        NSArray *priceRangeArray = @[priceRangeToPass];
        
        [parameters setObject:priceRangeArray forKey:@"priceRangeList"];
    }
    
    if (sale > 0) {
        [parameters setObject:@(sale) forKey:@"sale"];
    }
    
    if (sellerIds.count > 0) {
        [parameters setObject:sellerIds forKey:@"sellerIds"];
    }
    
    if (categoryIds.count > 0) {
        [parameters setObject:categoryIds forKey:@"categoryIds"];
    }
    
    if (brandIds.count > 0) {
        [parameters setObject:brandIds forKey:@"brandIds"];
    }
    
    [parameters setObject:availability forKey:@"availability"];
    
    //    NSLog(@"getSearchedProductsWithKeyword Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/products/search", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSearchedProductsWithKeyword Response:%@", responseObject);
        
        NSArray *productsDataArray = [[responseObject objectForKey:@"payload"] objectForKey:@"PRODUCTS"];
        
        NSInteger count = [[responseObject valueForKeyPath:@"payload.COUNT"] integerValue];
        
        //        NSLog(@"PRODUCTS:%@", productsDataArray);
        
        NSArray *productsArray = [self getArrayOfProductsWithProductsDataArray:productsDataArray tagId:0];
        
        //        for (Product *prod in productsArray) {
        //            NSLog(@"PROD NAME:%@ -- INSTOCK:%i", prod.name, prod.inStock);
        //        }
        
        NSDictionary *dictionaryToReturn = @{@"COUNT" : @(count), @"PRODUCTS" : productsArray};
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"getSearchedProductsWithKeyword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark - Mark
+(void) markAllNotificationsAsRead {
    NSDictionary *parameters = @{@"id" : @0};
    
    //    NSLog(@"markAllNotificationsAsRead Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/pushnotification/markread", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"markAllNotificationsAsRead Response:%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"markAllNotificationsAsRead FAIL ERROR:%@", [error localizedDescription]);
    }];
}

#pragma mark-instagram
-(void) getinstagramTags:(NSString *)tags acesstoken:(NSString *)acesstoken  completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"q": tags, @"access_token": acesstoken};
    NSLog(@"getinstagramTags parameters :%@",parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *str=@"https://api.instagram.com/v1/tags/search?";
    
    [manager GET:str parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        if (completionBlock) {
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getinstagramTags FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getinstagramTagPhotos:(NSString *)tag userId:(NSString *)userId nextTagId:(NSString *)nextTagId completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"tag": tag, @"userId": userId, @"next_max_tag_id":nextTagId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/instagram/tag/media",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (completionBlock) {
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getPDPMoreLikesWithProductId:(NSString *)productId PageNumber:(int)pageNumber completion:(receivedArray) completionBlock{
    NSDictionary *parameters = @{@"productId":productId, @"pageNumber":@(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/product/usersliked", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *likedUsersArray = [[responseObject objectForKey:@"payload"]valueForKey:@"LIKED_USERS"];
        
        if (completionBlock) {
            completionBlock(likedUsersArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getPDPMoreLikesWithProductId TIME OUT ERROR");
        }
        
        NSLog(@"getPDPMoreLikesWithProductId ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getMDPMoreLikesWithMediaId:(NSInteger)mediaId PageNumber:(int)pageNumber IGPageNumber:(int)instaPageNumber completion:(receivedArray)completionBlock{
    
    NSDictionary *parameters = @{@"mediaId":@(mediaId), @"pageNumber":@(pageNumber), @"instaPageNumber":@(instaPageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/post/usersliked", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"getMDPMoreLikesWithMediaId reponseObject:%@", responseObject);
        
        NSArray *likedUsersArray = [[responseObject objectForKey:@"payload"]valueForKey:@"LIKED_USERS"];
        
        if (completionBlock) {
            completionBlock(likedUsersArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getPDPMoreLikesWithProductId TIME OUT ERROR");
        }
        
        NSLog(@"getPDPMoreLikesWithProductId ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getSellerInfoWithSellerId:(NSInteger) sellerId completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"id": @(sellerId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/seller/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *dictionary = [dict objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getSellerInfoWithSellerId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void) getSellerPostsWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(sellerId), @"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/seller/posts", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSellerPostsWithSellerId responseObject:%@", responseObject);
        
        NSArray *mediasArray = [[responseObject objectForKey:@"payload"] objectForKey:@"SELLER_POSTS"];
        
        NSArray *arrayOfMedia = [self getArrayOfMediaFromMediasArray:mediasArray];
        
        if (completionBlock) {
            completionBlock(arrayOfMedia);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getSellerPostsWithSellerId FAIL ERROR:%@", [error localizedDescription]);
    }];
}

//-(void) getFollowersWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
//    NSDictionary *parameters = @{@"id": @(sellerId), @"pageNumber": @(pageNumber)};
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager GET:[NSString stringWithFormat:@"%@/seller/followers", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//
//        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
//        NSArray *usersArray = [[dict objectForKey:@"payload"] objectForKey:@"USERS"];
//
//        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
//
//        for (NSDictionary *userDictionary in usersArray) {
//            User *user = [[User alloc] initWithDictionary:userDictionary];
//
//            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
//                int followingId = [[usersDict objectForKey:@"userId"] intValue];
//
//                if (user.userId == followingId) {
//                    user.following = YES;
//                }
//            }
//
//            [usersArrayToReturn addObject:user];
//        }
//
//        if (completionBlock) {
//            completionBlock(usersArrayToReturn);
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"Seller Followers FAIL ERROR:%@", [error localizedDescription]);
//    }];
//}

-(void) getFollowersWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"id": @(sellerId), @"pageNumber": @(pageNumber), @"version" : version};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/seller/followers", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *usersCurrentUserIsFollowingArray = [[dict objectForKey:@"payload"] objectForKey:@"USER_SOCIAL_ACTION"];
        NSArray *usersArray = [[dict objectForKey:@"payload"] objectForKey:@"USERS"];
        
        NSMutableArray *usersArrayToReturn =[[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSDictionary *userDictionary in usersArray) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            for (NSDictionary *usersDict in usersCurrentUserIsFollowingArray) {
                int followingId = [[usersDict objectForKey:@"userId"] intValue];
                
                if (user.userId == followingId) {
                    //                    user.following = YES;
                    user.following = [[usersDict objectForKey:@"follow"] boolValue];
                    user.isPendingApproval = [[usersDict objectForKey:@"isApprovalPending"] boolValue];
                }
            }
            
            [usersArrayToReturn addObject:user];
        }
        
        if (completionBlock) {
            completionBlock(usersArrayToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Seller Followers FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getTopStoresWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/seller/topstores", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *TopStoresArray = [[responseObject objectForKey:@"payload"]valueForKey:@"SELLERS"];
        
        if (completionBlock) {
            completionBlock(TopStoresArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getTopStores  TIME OUT ERROR");
        }
        
        NSLog(@"getTopStores ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getTopProfilesWithPageNumber:(NSInteger)pageNumber completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/get/topprofiles", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getTopProfilesWithPageNumber reponseObject:%@", responseObject);
        
        NSDictionary *userDictionaries = responseObject;
        
        NSMutableArray *arrayOfUsers = [[NSMutableArray alloc] initWithCapacity:40];
        
        for (NSDictionary *userDictionary in userDictionaries) {
            User *user = [[User alloc] initWithDictionary:userDictionary];
            
            [arrayOfUsers addObject:user];
        }
        
        //        NSDictionary *dictionaryToPass = @{@"Users": arrayOfUsers};
        
        if (completionBlock) {
            completionBlock(arrayOfUsers);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getTopProfiles TIME OUT ERROR");
        }
        NSLog(@"getTopProfiles ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getHotDealsWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/deals/top", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getHotDealsWithPageNumber responseObject:%@", responseObject);
        
        NSArray *hotDealsArray = [[responseObject objectForKey:@"payload"]valueForKey:@"PRODUCTS"];
        
        //        NSLog(@"reponseob:%@", responseObject);
        
        if (completionBlock) {
            completionBlock(hotDealsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getHotDeals TIME OUT ERROR");
        }
        NSLog(@"getHotDeals ERROR:%@", [error localizedDescription]);
    }];
}

//-(void)getSellersImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
//    NSDictionary *parameters = @{@"id": @(userId), @"pageNumber": @(pageNumber)};
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager GET:[NSString stringWithFormat:@"%@/user/followedbyme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//
//        NSArray *sellerArray=[[dict objectForKey:@"payload"] objectForKey:@"SELLERS"];
//        if (completionBlock) {
//            completionBlock(sellerArray);
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"SellersIamFollowing FAIL ERROR:%@", [error localizedDescription]);
//    }];
//}

-(void)getSellersImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock {
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/sellers/followedbyme", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //        NSLog(@"getSellersImFollowing responseObject:%@", responseObject);
        
        NSArray *sellerArray=[[responseObject objectForKey:@"payload"] objectForKey:@"SELLERS"];
        if (completionBlock) {
            completionBlock(sellerArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"SellersIamFollowing FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getNewArrivalsWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock{
    
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/product/newarrivals", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *newArrivalsArray = [[responseObject objectForKey:@"payload"]valueForKey:@"PRODUCTS"];
        
        if (completionBlock) {
            completionBlock(newArrivalsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getNewArrivals TIME OUT ERROR");
        }
        NSLog(@"getNewArrivals ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getDealSellersImFollowing:(int)pageNumber completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/seller/withdeals", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *newArrivalsArray = [[responseObject objectForKey:@"payload"]valueForKey:@"SELLERS"];
        
        if (completionBlock) {
            completionBlock(newArrivalsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"DealSellersImFollowing TIME OUT ERROR");
        }
        NSLog(@"DealSellersImFollowing ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postFacebookConnection:(NSDictionary*)userFacebookInfo completion:(receivedArray)completionBlock{
    NSDictionary *parameters = userFacebookInfo;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/syw/createuserfb", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject valueForKey:@"error"];
        //        NSLog(@"Post User Facebook Information:%@", responseObject);
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Post User Facebook Information ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postDeleteSocialprofile:(NSString*)socialProfile completion:(void(^)(void))completionBlock{
    NSDictionary *parameters = @{@"socialProfile": socialProfile};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/deletesocialprofile", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Post Delete Social Profile:%@", responseObject);
        if (completionBlock) {
            completionBlock();
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Post Delete Social Profile ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getSYWMemberNumberWithEmail:(NSString*)sywEmail completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"sywEmail":sywEmail};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/user/syw/getmembernumber", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *newArrivalsArray = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(newArrivalsArray);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getSYWMemberNumber TIME OUT ERROR");
        }
        NSLog(@"getSYWMemberNumber ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postSYWMemberValidatePin:(NSString*)sywMemberNumber sywPinNumber:(NSString*)sywPinNumber completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"sywMemberNumber": sywMemberNumber, @"sywMemberPinNumber":sywPinNumber};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/syw/validatepin", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Post SYW Member Pin Validate:%@", responseObject);
        NSArray *array = [responseObject objectForKey:@"payload"];
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Post SYW Member Pin Validate ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void) getUser:(receivedDictionary) completionBlock {
    NSInteger userId = [self getUserId];
    
    NSDictionary *parameters = @{@"id":@(userId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //Not a guest
    if (userId > 0) {
        
        [manager GET:[NSString stringWithFormat:@"%@/user/getUser", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            //            NSLog(@"getUser responseObject:%@", responseObject);
            
            //            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            //
            //            if (!errorDictionary) {
            //                [self saveUserInfo:responseObject];
            //            }
            
            if (completionBlock) {
                
                //                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSessionKey];
                
                BOOL userIsActivated = [[responseObject valueForKeyPath:@"payload.USER.confirmRegistrationStatus"] boolValue];
                
                NSDictionary *sywDict = [responseObject valueForKeyPath:@"payload.USER.userSyw"];
                if (sywDict.count > 0) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSywConnected"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSywConnected"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                // NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:kIsSywConnected]);
                
                //                [[NSUserDefaults standardUserDefaults] setBool:userIsActivated forKey:kConfirmedKey];
                //                [[NSUserDefaults standardUserDefaults] synchronize];
                //                BOOL userIsActivated = [[NSUserDefaults standardUserDefaults] boolForKey:kConfirmedKey];
                
                [[NSUserDefaults standardUserDefaults] setBool:!userIsActivated forKey:kShouldDisplayBannerKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                completionBlock(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if (error.code == NSURLErrorTimedOut) {
                NSLog(@"getUser TIME OUT ERROR");
            }
            NSLog(@"getUser ERROR:%@", [error localizedDescription]);
        }];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldDisplayBannerKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void) removeSocialProfile:(NSString *) socialMediaType completion:(receivedDictionary) completionBlock {
    NSDictionary *parameters = @{@"socialProfile" : socialMediaType};
    
    //    NSLog(@"removeSocialProfile Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/deletesocialprofile", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"removeSocialProfile Response:%@", responseObject);
        
        NSDictionary *dictionaryToReturn = [responseObject valueForKeyPath:@"payload.USER"];
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"removeSocialProfile FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postConnectSYWAccount:(NSString*)sywMemberNumber sywEmail:(NSString*)sywEmail FountId:(NSString*)userId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"sywMemberNumber": sywMemberNumber, @"sywEmail":sywEmail, @"userId":userId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/syw/createusersyw", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"Post SYW Member Pin Validate:%@", responseObject);
        NSArray *array = [responseObject objectForKey:@"payload"];
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Post SYW Member Pin Validate ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getSYWMemberDetail:(NSString*)userId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"userId":userId};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/syw/getusersywdetails", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSYWMemberDetail responseObject:%@", responseObject);
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getSYWMemberDetail TIME OUT ERROR");
        }
        NSLog(@"getSYWMemberDetail ERROR:%@", [error localizedDescription]);
    }];
}

+(void) getOrderDetailsWithOrderId:(NSInteger) orderId completion:(receivedDictionary) completionBlock {
    
    NSDictionary *parameters = @{@"id": @(orderId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/order/getorderdetails", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getOrderDetailsWithOrderId responseObject:%@", responseObject);
        
        NSDictionary *dictionaryToReturn = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dictionaryToReturn);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getOrderDetailsWithOrderId TIME OUT ERROR");
        }
        NSLog(@"getOrderDetailsWithOrderId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getMyOrders:(NSInteger)userId pageNumber:(int)pageNumber completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"id":@(userId), @"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/order/getorders", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSLog(@"getMyOrder responseObject:%@", responseObject);
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getMyOrders TIME OUT ERROR");
        }
        NSLog(@"getMyOrders ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getRecommendProductsWithProductId:(NSInteger)productId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"productId": @(productId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/reco/products/bylikers", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getOrderDetailsWithOrderId responseObject:%@", responseObject);
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getRecommendProductsWithProductId TIME OUT ERROR");
        }
        NSLog(@"getRecommendProductsWithProductId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getDisplaynameAvailabilityWithDisplayName:(NSString*)displayName completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"displayName": displayName};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/isavaialble", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"checkDisplaynameAvailabilityWithDisplayName TIME OUT ERROR");
        }
        NSLog(@"checkDisplaynameAvailabilityWithDisplayName ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postUpdateEditProfile:(NSDictionary *)profileDict completion:(receivedDictionary) completionBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/updateprofile", WEB_DOMAIN] parameters:profileDict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"RESPONSE OBJ:%@", responseObject);
        
        if ([responseObject objectForKey:@"error"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[responseObject objectForKey:@"error"] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            // Call is successful
            if (completionBlock) {
                completionBlock(responseObject);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postUpdateEditProfile FAIL ERROR:%@", [error localizedDescription]);
    }];
}


+(void) getProductCountWithKeyword:(NSString *) keyword sellerIds:(NSArray *) sellerIds brandIds:(NSArray *) brandIds categoryIds:(NSArray *) categoryIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale availability:(NSString *) availability completion:(receivedDictionary)completionBlock {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (keyword.length > 0) {
        [parameters setObject:keyword forKey:@"keyword"];
    }
    
    //    [parameters setObject:@(pageNumber) forKey:@"pageNumber"];
    //    [parameters setObject:sortBy forKey:@"sortBy"];
    
    //    int count = 0;
    
    //    NSLog(@"PRICE R ARR:%@", priceRangesArray);
    
    //    if (priceRangesArray.count > 0) {
    //        NSMutableDictionary *priceRangeToPass = [[NSMutableDictionary alloc] initWithCapacity:10];
    //
    //        for (NSDictionary *priceRangeDictionary in priceRangesArray) {
    //            [priceRangeToPass setObject:priceRangeDictionary forKey:@(count)];
    //            count++;
    //        }
    //        NSArray *priceRangeArray = @[priceRangeToPass];
    //
    //        [parameters setObject:priceRangeArray forKey:@"priceRangeList"];
    //    }
    //
    //    if (sale > 0) {
    //        [parameters setObject:@(sale) forKey:@"sale"];
    //    }
    
    if (sellerIds.count > 0) {
        [parameters setObject:sellerIds forKey:@"sellerIds"];
    }
    
    //    if (categoryIds.count > 0) {
    //        [parameters setObject:categoryIds forKey:@"categoryIds"];
    //    }
    
    if (brandIds.count > 0) {
        [parameters setObject:brandIds forKey:@"brandIds"];
    }
    
    //    [parameters setObject:availability forKey:@"availability"];
    
    //    NSLog(@"getProductCountWithSellerIds Param:%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/products/count", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getProductCountWithSellerIds responseObject:%@", responseObject);
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getProductCountWithSellerIds TIME OUT ERROR");
        }
        NSLog(@"getProductCountWithSellerIds ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postUpdateProfileImageWithString:(NSString*)imageString completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"image": imageString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/updateprofilepic", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"loginWithEmail Response:%@", responseObject);
        
        NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
        
        if (!errorDictionary) {
            [self saveUserInfo:responseObject];
        }
        
        if (completionBlock) {
            completionBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postUpdateProfileImageWithString FAIL ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getImportedMeidaWithId:(NSString*)instagramId completion:(receivedArray) completionBlock{
    
    NSDictionary *parameters = @{@"instagramId": instagramId};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/media/isimported", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getImportedMeidaWithId TIME OUT ERROR");
        }
        NSLog(@"getImportedMeidaWithId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postValidateCurrentPassword:(NSString*)currentPassword completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"password": currentPassword};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/validate/password", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postValidateCurrentPassword FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postChangePasswordWithOldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmPassword:(NSString*)confirmPassword completion:(receivedDictionary)completionBlock{
    
    NSDictionary *parameters = @{@"oldPassword": oldPassword, @"newPassword":newPassword, @"newPasswordConfirm":confirmPassword};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/change/password", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postChangePasswordWithOldPassword FAIL ERROR:%@", [error localizedDescription]);
    }];
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

-(void)postValidatePhoneNumberWithCountryCode:(NSInteger)countryCode phoneNumber:(NSInteger)phoneNumber completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"countryCode": @(countryCode), @"phoneNumber":@(phoneNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/validatephone", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postValidatePhoneNumberWithCountryCode FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postRegisterPhoneNumberWithCountryCode:(NSInteger)countryCode phoneNumber:(NSInteger)phoneNumber verifyCode:(NSInteger)verifyCode completion:(receivedDictionary)completionBlock{
    NSDictionary *parameters = @{@"countryCode": @(countryCode), @"phoneNumber":@(phoneNumber),@"code":@(verifyCode)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/user/registerphone", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"postRegisterPhoneNumberWithCountryCode FAIL ERROR:%@", [error localizedDescription]);
    }];
    
    
}

+(void)getSYWMemberDetail:(receivedDictionary) completionBlock {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey];
    
    NSDictionary *parameters = @{@"userId":userId};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/syw/getusersywdetails", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSLog(@"getSYWMemberDetail responseObject:%@", responseObject);
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getSYWMemberDetail TIME OUT ERROR");
        }
        NSLog(@"getSYWMemberDetail ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getReportReasonsWithComplaintType:(NSString*)complaintType completion:(receivedArray)completionBlock{
    
    NSDictionary *parameters = @{@"complaintType": complaintType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/complaint/reasons/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getReportReasonsWithComplaintType TIME OUT ERROR");
        }
        NSLog(@"getReportReasonsWithComplaintType ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postReportWithComplainerId:(NSInteger)complainerId complaintType:(NSString*)complaintType mediaId:(NSInteger)mediaId userId:(NSInteger)userId complaintReasonId:(NSInteger)complaintReasonId completion:(receivedDictionary)completionBlock{
    
    NSDictionary *parameters = @{@"complainer[id]":@(complainerId), @"complaintType":complaintType, @"media[id]":@(mediaId),@"user[id]":@(userId),@"complaintReason[id]":@(complaintReasonId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/complaint/create", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postReportWithComplainerId TIME OUT ERROR");
        }
        NSLog(@"postReportWithComplainerId ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postBlockWithId:(NSInteger)userId completion:(receivedArray)completionBlock{
    NSDictionary *parameter = @{@"id":@(userId)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/block", WEB_DOMAIN] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postBlockWithId TIME OUT ERROR");
        }
        NSLog(@"postBlockWithId ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postUnblockWithId:(NSInteger)userId completion:(receivedArray)completionBlock{
    
    NSDictionary *parameter = @{@"id":@(userId)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/unblock", WEB_DOMAIN] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postUnblockWithId TIME OUT ERROR");
        }
        NSLog(@"postUnblockWithId ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void) deleteAddressWithId:(NSInteger) addressId {
    NSDictionary *parameter = @{@"address[id]":@(addressId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/address/delete", WEB_DOMAIN] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"deleteAddressWithId responseObject:%@", responseObject);
        
        //        NSArray *array = [responseObject objectForKey:@"payload"];
        //
        //        if (completionBlock) {
        //            completionBlock(array);
        //        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"deleteAddressWithId TIME OUT ERROR");
        }
        NSLog(@"deleteAddressWithId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postDisablePrivateMode:(receivedArray)completionBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/userprofile/disableprivatesetting", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postDisbalePrivateMode TIME OUT ERROR");
        }
        NSLog(@"postDisbalePrivateMode ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postEnablePrivateMode:(receivedArray)completionBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/userprofile/enableprivatesetting", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postEnablePrivateMode TIME OUT ERROR");
        }
        NSLog(@"postEnablePrivateMode ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getRequestedToFollowNotificationWithPageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock{
    NSDictionary *parameters = @{@"pageNumber": @(pageNumber)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/pushnotification/followrequests/get", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dictionary = [responseObject objectForKey:@"payload"];
        //        NSDictionary *requestDict = [responseObject valueForKeyPath:@"payload.PUSHNOTIFICATIONS_FOLLOW_REQUEST"];
        
        //        Notification *requestedNotification = [[Notification alloc]initWithRequestedFollowDictionary:requestDict];
        
        //        NSLog(@"getRequestedToFollowNotificationWithPageNumber responseObject:%@", responseObject);
        
        if (completionBlock) {
            completionBlock(dictionary);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getRequestedToFollowNotificationWithPageNumber FAIL ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postAcceptFollowRequestWithId:(NSInteger)initiatorId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"id": @(initiatorId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/acceptfollow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postAcceptFollowRequestWithId TIME OUT ERROR");
        }
        NSLog(@"postAcceptFollowRequestWithId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)postDenyFollowRequestWithId:(NSInteger)initiatorId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"id": @(initiatorId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/user/denyfollow", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postDenyFollowRequestWithId TIME OUT ERROR");
        }
        NSLog(@"postDenyFollowRequestWithId ERROR:%@", [error localizedDescription]);
    }];
    
}

+(void) getReferralCodeCompletion:(receivedDictionary) completionBlock {
    //    NSMutableDictionary *parameters;
    //
    //    [parameters setObject:name forKey:@"userReferral.name"];
    //
    //    if (phoneNumber.length > 0) {
    //        [parameters setObject:phoneNumber forKey:@"userReferral.phone"];
    //    }
    //
    //    if (email.length > 0) {
    //        [parameters setObject:email forKey:@"userReferral.email"];
    //    }
    
    //    NSDictionary *parameters;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/user/referral", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"Referral response:%@", responseObject);
        
        //        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock([responseObject objectForKey:@"payload"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getReferralCodeCompletion TIME OUT ERROR");
        }
        NSLog(@"getReferralCodeCompletion ERROR:%@", [error localizedDescription]);
    }];
}

+(void) referFriendWithName:(NSString *) name phoneNumber:(NSString *) phoneNumber email:(NSString *) email completion:(receivedDictionary) completionBlock{
    
    NSDictionary *parameters = @{@"userReferral.name":name, @"userReferral.phone":phoneNumber, @"userReferral.email":email};
    //NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithCapacity:3];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/referral/invite", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(dict);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"referFriendWIthName TIME OUT ERROR");
        }
        NSLog(@"referFriendWIthName ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)postRefountMediaWithMediaId:(NSInteger)mediaId completion:(receivedArray)completionBlock{
    NSDictionary *parameters = @{@"id": @(mediaId)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/media/refount", WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"postRefountMediaWithMediaId TIME OUT ERROR");
        }
        NSLog(@"postRefountMediaWithMediaId ERROR:%@", [error localizedDescription]);
    }];
    
}

-(void)getRefountUsersWithMediaId:(NSInteger)mediaId pageNumber:(NSInteger)pageNumber completion:(receivedArray) completionBlock{
    NSDictionary *parameters = @{@"id": @(mediaId), @"pageNumber":@(pageNumber)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/media/refountusers",WEB_DOMAIN] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock(array);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getRefountUsersWithMediaId TIME OUT ERROR");
        }
        NSLog(@"getRefountUsersWithMediaId ERROR:%@", [error localizedDescription]);
    }];
}

-(void)getSywUserRegistrerUrl:(receivedArray)completionBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/syw/getuserregisterurl", WEB_DOMAIN] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //        NSArray *array = [responseObject objectForKey:@"payload"];
        
        if (completionBlock) {
            completionBlock([responseObject objectForKey:@"payload"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == NSURLErrorTimedOut) {
            NSLog(@"getSywUserRegistrerUrl TIME OUT ERROR");
        }
        NSLog(@"getSywUserRegistrerUrl ERROR:%@", [error localizedDescription]);
    }];
    
    
}



@end
