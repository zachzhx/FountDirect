//
//  ServiceLayer.h
//  On Demand Concierge
//
//  Created by Rush on 5/26/15.
//  Copyright (c) 2015 Sears. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Address;
@class VisualTag;
@class Product;
@class Media;

typedef void(^receivedDictionary)(NSDictionary *dictionary);
typedef void(^receivedArray)(NSArray *array);

@interface ServiceLayer : NSObject <NSURLSessionDelegate>

/**
 *  Registers a new account through Spree
 *  @param email: User's email
 *  @param password: User's password
 *  @param username: User's username
 */
-(void) registerWithEmail:(NSString *) email password:(NSString *) password username:(NSString *) username completion:(void(^)(void)) completionBlock;

/**
 *  Registers a new account through Instagram
 *  @param email: User's email
 *  @param password: User's password
 *  @param username: User's username
 *  @param instagramId: Instagram Id
 */
-(void) registerViaInstagramWithEmail:(NSString *) email password:(NSString *) password username:(NSString *) username instagramId:(NSInteger) instagramId completion:(void(^)(void)) completionBlock;

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

-(void) loginViaInstagram:(int) userId completion:(void(^)(void)) completionBlock;

/**
 *  Gets 20 instagram images and their information
 *  @param pageNumber
 *  @return Array of medias
 */
-(void) getLatestInstagramImagesWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;


//+(void) getMediaWithMediaId:(NSInteger) mediaId completion:(void(^)(Media *media)) completionBlock;
+(void) getMediaWithMediaId:(NSInteger) mediaId completion:(receivedDictionary) completionBlock;

/**
 *  Gets prodctDetails users have selcted
 */
-(void) getProductDetailsWithProductId:(NSString *) productId completion:(receivedDictionary) completionBlock;

/**
 *  Gets relevent Posts users have selcted
 */
-(void) getReleventPostsWithProductId:(NSString *) productId pageNumber:(NSString*)aPageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets items users have in cart and saves the amount locally
 *  @return Array of products
 */
-(void) getCartProducts:(receivedArray) completionBlock;

/**
 *  Gets user's saved displayname
 *  @return Display name
 */
+(NSString *) getDisplayName;

/**
 *  Likes the media
 *  @param mediaId
 *  @return The Media
 */
-(void) likeMedia:(NSInteger) mediaId completion:(receivedDictionary) completionBlock;

/**
 *  Unlikes the media
 *  @param mediaId
 *  @return The Media
 */
-(void) unlikeMedia:(NSInteger) mediaId completion:(receivedDictionary) completionBlock;

/**
 *  Gets product tags
 *  @param mediaId
 *  @return product tags
 */
-(void) getProductTagsWithMediaId:(NSInteger) mediaId completion:(receivedArray) completionBlock;

/**
 *  Adds products to tag then adds tag to media
 *  @param mediaId
 *  @param tagLocation - Between the values 0 - 1
 *  @param productsArray - Array of products
 *  @return Dictionary response from server
 */
-(void) addTagToMediaId:(NSInteger) mediaId tagLocation:(CGPoint) tagLocation productIdArray:(NSArray *) productsArray completion:(receivedDictionary) completionBlock;

/**
 *  Adds products to tag
 *  @param mediaId
 *  @param productsArray - Array of products
 *  @return Dictionary response from server
 */
-(void) addProductToTagId:(NSUInteger) tagId productIdArray:(NSArray *) productsArray completion:(receivedArray) completionBlock;

/**
 *  Deletes tag
 *  @param tagId - Tag's id
 *  @return Dictionary response from server
 */
-(void) deleteTagWithTagId:(NSUInteger) tagId completion:(receivedDictionary) completionBlock;

/**
 *  Deletes product in a tag
 *  @param tag - VisualTag that product belongs to
 *  @param product - Product to be deleted
 *  @return Dictionary response from server
 */
-(void) deleteProductWithProduct:(Product *) product tag:(VisualTag *) tag completion:(receivedDictionary) completionBlock;

/**
 *  Likes a product
 *  @param productId - Product's id
 *  @return Dictionary response from server
 */
-(void) likeProductWithProductId:(NSUInteger) productId completion:(receivedDictionary) completionBlock;

/**
 *  Unlike a product
 *  @param productId - Product's id
 *  @return Dictionary response from server
 */
-(void) unlikeProductWithProductId:(NSUInteger) productId completion:(receivedDictionary) completionBlock;

/**
 *  Checks to see if profile clicked is a brand
 *  @param mediaId - Media's id
 *  @return Dictionary response from server
 */
-(void) checkMediaOwnerWithMediaId:(NSInteger) mediaId completion:(receivedDictionary) completionBlock;

/**
 *  Gets information about a certain brand by id
 *  @param brandId - Brand's id
 *  @return brand information Dictionary
 */
-(void) getBrandInfoWithBrandId:(NSInteger) brandId completion:(receivedDictionary) completionBlock;

-(void) getFilteredProductCountWithFilter:(NSString *) filterRequest completion:(receivedDictionary) completionBlock;

/**
 *  Gets information about a certain brand by id
 *  @param profileId - Brand's id, otherwise -1 will be passed
 *  @param relevancy - relevancy String
 *  @param pageNumber - Starts at 1
 *  @param filterRequest - Filter to apply (ex. LIKED_PRODUCTS)
 *  @return Array of products & count in a dictionary
 */
-(void) getFilteredProductsBySortFilter:(NSString *) relevancy userId:(NSInteger) userId pageNumber:(NSInteger) pageNumber filterRequest:(NSString *) filterRequest availabililty:(NSString *) availability completion:(receivedDictionary) completionBlock;

-(void) getFilteredProductsBySortFilter:(NSString *) sortByFilter userId:(NSInteger) userId pageNumber:(NSInteger) pageNumber filterRequest:(NSString *) filterRequest availabililty:(NSString *) availability version:(NSString *) version completion:(receivedDictionary) completionBlock;

/**
 *  Gets information about a person
 *  @param userId - User's id
 *  @return User's information Dictionary
 */
-(void) getUserInformationWithUserId:(NSInteger) userId completion:(receivedDictionary) completionBlock;

/**
 *  Gets User's Posts
 *  @param userId - User's id
 #  @param pageNumber - Pagination for infinite scroll
 *  @return Array of Media
 */
-(void) getUserPostsWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets Brand's Posts
 *  @param brandId - Brand's id
 #  @param pageNumber - Pagination for infinite scroll (Starts at 1)
 *  @return Array of Media
 */
-(void) getBrandPostsWithBrandId:(NSInteger) brandId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

/**
 *  Gets Followers
 *  @param userId - User's id
 #  @param pageNumber - Pagination for infinite scroll (Starts at 1)
 *  @return Array of Users (User Objects)
 */
//-(void) getFollowersWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void) getFollowersWithUserId:(NSInteger) userId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock;

/**
 *  Gets Followers
 *  @param brandId - Brand's id
 #  @param pageNumber - Pagination for infinite scroll (Starts at 1)
 *  @return Array of Brands(User Objects)
 */
//-(void) getFollowersWithBrandId:(NSInteger) brandId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;
-(void) getFollowersWithBrandId:(NSInteger) brandId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock;

/**
 *  Gets User's and Brands that user is following
 *  @param userId - User's id
 #  @param pageNumber - Pagination for infinite scroll (Starts at 1)
 *  @return Array of Users
 */
//-(void) getUsersAndBrandsImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

-(void) getUsersAndBrandsImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock;

/**
 *  Follows brand
 *  @param brandId - Brand's id
 *  @return Dictionary response
 */
-(void) followBrand:(NSInteger) brandId completion:(receivedDictionary) completionBlock;

/**
 *  Unfollows brand
 *  @param brandId - Brand's id
 *  @return Dictionary response
 */
-(void) unfollowBrand:(NSInteger) brandId completion:(receivedDictionary) completionBlock;

/**
 *  Follows User
 *  @param brandId - Brand's id
 *  @return Dictionary response
 */
-(void) followUser:(NSInteger) userId completion:(receivedDictionary) completionBlock;

/**
 *  Unfollows User
 *  @param userId - User's id
 *  @return Dictionary response
 */
-(void) unfollowUser:(NSInteger) userId completion:(receivedDictionary) completionBlock;

/**
 *  follow / Unfollows Seller
 *  @param userId - Seller's id
 *  @return Dictionary response
 */
-(void) followSeller:(NSInteger)sellerId completion:(receivedDictionary)completionBlock;

-(void) unfollowSeller:(NSInteger)sellerId completion:(receivedDictionary)completionBlock;


/**
 *  Gets commission of current user
 *  @return User's commission Dictionary
 */
-(void) getUserCommission:(receivedDictionary) completionBlock;

/**
 *  Gets Points of current user
 *  @return User's point Dictionary
 */
-(void) getUserPoints:(receivedDictionary) completionBlock;

/**
 *  Gets media user has liked
 *  @param pageNumber - Page Number - Starts at 1
 *  @return Array of Media
 */
//-(void) getUserLikedMediaWithPageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;
-(void) getUserLikedMediaWithPageNumber:(NSInteger) pageNumber version:(NSString *) version userId:(NSInteger) userId completion:(receivedArray) completionBlock;

//getUserId
-(NSInteger) getUserId;

/**
 * Get the shopping cart products
 * @param userId - user's id
 * @param twoTapForceSync - true
 */
-(void) getShoppingCartProductsWithUserId:(NSString *) userId twoTapForceSync:(BOOL)twoTapForce completion:(receivedDictionary) completionBlock;

/**
 *get the Import photos
 *@param userId - user's id
 *@param next_max_id -
 */
-(void) getImportPhotosWithUserId:(NSString *) useId nextMaxId:(NSString *)nextMaxId completion:(receivedDictionary) completionBlock;

/**
 *get the Import Feeds
 *@param userId - user's id
 *@param next_max_id -
 */
-(void) getImportFeedsWithUserId:(NSString *) userId nextMaxId:(NSString *)nextMaxId completion:(receivedDictionary) completionBlock;

/**
 *Gets the products that are going to be ordered
 *@param arrayOfShoppingCartProductId - Array of shopping cart product id's
 *@return Shopping cart JSON Dictionary
 */
+(void) getCheckoutProducts:(NSArray *) arrayOfShoppingCartProductId  completion:(receivedDictionary) completionBlock;
+(void) getCheckoutProducts:(NSArray *) arrayOfShoppingCartProductId sellerCouponsDictionary:(NSDictionary *) sellerCouponsDictionary  completion:(receivedDictionary) completionBlock;

/**
 *  Adds Selected images
 *  @param userId - user's id
 *  @param medias: User's username
 *  returns the response Dictionary
 */
-(void) addImageMedia:(NSMutableDictionary *)mediaDict completion:(receivedDictionary) completionBlock;

/**
 *  Gets sellers depending on which filter is passed in
 *  @param filter - Filter used to determine sellers (e.g. ARRIVALS, LIKED_PRODUCTS, SAVED_PRODUCTS, SALE).
 *  returns The array of Seller objects
 */
-(void) getSellersByFilter:(NSString *) filter completion:(receivedArray) completionBlock;

/**
 *  Gets seller's products
 *  @param sellerId - Seller's Id
 *  @param filter - Filter used to determine sellers (e.g. ARRIVALS, LIKED_PRODUCTS, SAVED_PRODUCTS, SALE).
 *  @param pageNumber - Page number for pagination (Starts at 1)
 *  returns The a dictionary with the count and Array of products
 */
+(void) getSellerProductsWithSellerId:(NSInteger) sellerId filter:(NSString *) filter pageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock;

#pragma mark - Shipping API
-(void) verifyAddressWithAddress:(Address *) address completion:(receivedDictionary) completionBlock;

/**
 *  Gets user's saved shipping addresses
 *  @param addressType - String for addresstype (e.g SHIPPING)
 *  returns The array of Addresses
 */
+(void) getShippingAddressWithAddressType:(NSString *) addressType completion:(receivedArray) completionBlock;

/**
 *  Adds shipping address to database
 *  @param addressType - String for addresstype (e.g SHIPPING)
 *  returns The array of Addresses
 */
-(void) addShippingAddressWithAddress:(Address *) address completion:(void(^)(Address *address)) completionBlock;

#pragma mark - Place Order API
/**
 *  Places user's order
 *  @param dict - dictionary of objects to send
 *  returns The response dictionary
 */
-(void) purchase:(NSDictionary *) dict completion:(receivedDictionary) completionBlock;

/**
 *Delect the cart product
 *@param shoppingCart[id] - shoppingCart's Id
 *@param cartProduct[id] - cartProduct's Id
 */
-(void) postDelectWithShoppingCartId:(NSString *)shoppingCartId cartProductId:(NSString *)cartProductId productMetaDataId:(NSInteger) productMetaDataId completion:(receivedDictionary) completionBlock;


/**
 *Save for later the cart product
 *@param cartProduct[id] - cartProduct's Id
 */
-(void) postSaveForLaterwithProductId:(NSString *)cartProductId completion:(receivedDictionary) completionBlock;

/**
 *  Add the product to cart
 *  @param userId - user's id
 *  @param product - productArray
 *  returns the response Dictionary
 */
-(void) postAddToCart:(NSDictionary *)productDict completion:(receivedDictionary) completionBlock;

/**
 *Get VisualTagId
 */
-(void) getVisualTagId:(NSString *)relevantPostId productId:(NSString*)productId completion:(receivedDictionary) completionBlock;

/**
 *Add the shop page product to cart
 */
-(void) postShopAddToCart:(NSDictionary *)productDict completion:(receivedDictionary) completionBlock;

#pragma mark - Push Notifications
/**
 *  Updates device token
 */
-(void) updateDeviceTokenWithCompletionBlock:(receivedDictionary) completionBlock;

/**
 *Get Notification Tab Information
 *param pageNumber
 */
-(void) getPushnotificationWithPageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock;

/**
 *  Get Notification Tab Information
 *  param pageNumber - Pagenumber - Starts at 1
 */
-(void) getActivityWithPageNumber:(NSInteger) pageNumber version:(NSString*)version completion:(receivedDictionary) completionBlock;

#pragma mark - Google Analytics
/**
 *  Adds an event to Google Analytics
 *  param category - *Required* Category that appears in Google Analytics
 *  param actionName - *Required* Name to describe the action user took
 *  param label - Further label to distinguish events
 *  param value - number of times event called (Usually 1)
 */
+(void) googleTrackEventWithCategory:(NSString *) category actionName:(NSString *) actionName label:(NSString *) label value:(NSInteger) value;

#pragma mark - Auto Update
/**
 *  Gets App Version
 */
+(void) getAppVersion:(receivedDictionary) completionBlock;

#pragma mark - Filter Request
/**
 *  Gets aggregation
 *  param keyword - word searched
 *  param sellerIds - Array of seller Ids (ids are strings).
 *  param categoryIds - Array of category Ids (ids are strings).
 *  param brandIds - Array of brand Ids (ids are strings).
 *  param priceRangesArray - Array of price range dictionary.
 *  param sale - Integer sale value - (eg. 40% is 40).
 *  returns - Dictionary of filter options.
 */
-(void) getAggregationWithKeyword:(NSString *) keyword sellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale completion:(receivedDictionary) completionBlock;

/**
 *  Gets Searched products based on filter
 *  param keyword - word searched
 *  param sellerIds - Array of seller Ids (ids are strings).
 *  param categoryIds - Array of category Ids (ids are strings).
 *  param brandIds - Array of brand Ids (ids are strings).
 *  param priceRangesArray - Array of price range dictionary.
 *  param sale - Integer sale value - (eg. 40% is 40).
 *  returns - Dictionary of filtered products.
 */
-(void) getSearchedProductsWithKeyword:(NSString *) keyword sortyBy:(NSString *) sortBy pageNumber:(NSInteger) pageNumber sellerIds:(NSArray *) sellerIds categoryIds:(NSArray *) categoryIds brandIds:(NSArray *) brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale availability:(NSString *) availability completion:(receivedDictionary) completionBlock;

+(void) markAllNotificationsAsRead;

//instagramTags
-(void) getinstagramTags:(NSString *)tags acesstoken:(NSString *)acesstoken  completion:(receivedDictionary) completionBlock;

//instagramMedia
-(void) getinstagramTagPhotos:(NSString *)tag userId:(NSString *)userId nextTagId:(NSString *)nextTagId completion:(receivedDictionary) completionBlock;

//PDPMoreLikes
-(void) getPDPMoreLikesWithProductId:(NSString *)productId PageNumber:(int)pageNumber completion:(receivedArray) completionBlock;

//MDPMoreLikes
-(void) getMDPMoreLikesWithMediaId:(NSInteger)mediaId PageNumber:(int)pageNumber IGPageNumber:(int)instaPageNumber completion:(receivedArray)completionBlock;

//Sellers Infomation:
-(void) getSellerInfoWithSellerId:(NSInteger) sellerId completion:(receivedDictionary) completionBlock;

-(void) getSellerPostsWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

//-(void) getFollowersWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;
-(void) getFollowersWithSellerId:(NSInteger) sellerId pageNumber:(NSInteger) pageNumber version:(NSString *) version completion:(receivedArray) completionBlock;

//Top Stores
-(void)getTopStoresWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock;

//Top Profiles
-(void)getTopProfilesWithPageNumber:(NSInteger)pageNumber completion:(receivedArray)completionBlock;

//Hot Deals:
-(void)getHotDealsWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock;

//New Arrivals:
-(void)getNewArrivalsWithPageNumber:(int)pageNumber completion:(receivedArray)completionBlock;

//Get sellers I am following
-(void)getSellersImFollowing:(NSInteger) userId pageNumber:(NSInteger) pageNumber completion:(receivedArray) completionBlock;

//Get Deals Sellers I am Following
-(void)getDealSellersImFollowing:(int)pageNumber completion:(receivedArray)completionBlock;

-(void) getUser:(receivedDictionary) completionBlock;

+(void) removeSocialProfile:(NSString *) socialMediaType completion:(receivedDictionary) completionBlock;

//Post and Connect Facebook user Information
-(void)postFacebookConnection:(NSDictionary*)userFacebookInfo completion:(receivedArray)completionBlock;

//Post Delete Social Network Connection
-(void)postDeleteSocialprofile:(NSString*)socialProfile completion:(void(^)(void))completionBlock;

//Get ShopYourWay Member Number
-(void)getSYWMemberNumberWithEmail:(NSString*)sywEmail completion:(receivedArray)completionBlock;

//Post ShopYourWay Member Validate Pin
-(void)postSYWMemberValidatePin:(NSString*)sywMemberNumber sywPinNumber:(NSString*)sywPinNumber completion:(receivedArray)completionBlock;

//Post Connecting SYW Member account
-(void)postConnectSYWAccount:(NSString*)sywMemberNumber sywEmail:(NSString*)sywEmail FountId:(NSString*)userId completion:(receivedArray)completionBlock;

//Get SYW Member Detail
-(void)getSYWMemberDetail:(NSString*)userId completion:(receivedArray)completionBlock;


+(void) getOrderDetailsWithOrderId:(NSInteger) orderId completion:(receivedDictionary) completionBlock;

//Get My orders
-(void)getMyOrders:(NSInteger)userId pageNumber:(int)pageNumber completion:(receivedDictionary)completionBlock;

//Recommend the products by liking a prodcut
-(void)getRecommendProductsWithProductId:(NSInteger)productId completion:(receivedArray)completionBlock;

//Check Display Name Availability:
-(void)getDisplaynameAvailabilityWithDisplayName:(NSString*)displayName completion:(receivedArray)completionBlock;

//Post Update the profile Information:
-(void)postUpdateEditProfile:(NSDictionary *)profileDict completion:(receivedDictionary) completionBlock;

//Post Update the profile image:
-(void)postUpdateProfileImageWithString:(NSString*)imageString completion:(receivedDictionary)completionBlock;

+(void) getProductCountWithKeyword:(NSString *) keyword sellerIds:(NSArray *) sellerIds brandIds:(NSArray *) brandIds categoryIds:(NSArray *) categoryIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger) sale availability:(NSString *) availability completion:(receivedDictionary)completionBlock;

//Check if the media has been imported yet
-(void)getImportedMeidaWithId:(NSString*)instagramId completion:(receivedArray) completionBlock;

//Check and validate the current password
-(void)postValidateCurrentPassword:(NSString*)currentPassword completion:(receivedDictionary)completionBlock;

//Save the password changes
-(void)postChangePasswordWithOldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword confirmPassword:(NSString*)confirmPassword completion:(receivedDictionary)completionBlock;

//Forgot Password to send Email to reset the password
-(void)postForgotPasswordwithEmail:(NSString*)email completion:(receivedDictionary)completionBlock;

//Validate Phone Number
-(void)postValidatePhoneNumberWithCountryCode:(NSInteger)countryCode phoneNumber:(NSInteger)phoneNumber completion:(receivedDictionary)completionBlock;

//Register Phone Number
-(void)postRegisterPhoneNumberWithCountryCode:(NSInteger)countryCode phoneNumber:(NSInteger)phoneNumber verifyCode:(NSInteger)verifyCode completion:(receivedDictionary)completionBlock;

//Get SYW Member Detail
+(void)getSYWMemberDetail:(receivedDictionary) completionBlock;

//Get Report Reason:
-(void)getReportReasonsWithComplaintType:(NSString*)complaintType completion:(receivedArray)completionBlock;

//Post Report
-(void)postReportWithComplainerId:(NSInteger)complainerId complaintType:(NSString*)complaintType mediaId:(NSInteger)mediaId userId:(NSInteger)userId complaintReasonId:(NSInteger)complaintReasonId completion:(receivedDictionary)completionBlock;

//Post Block User
-(void)postBlockWithId:(NSInteger)userId completion:(receivedArray)completionBlock;

//Post Unblock User
-(void)postUnblockWithId:(NSInteger)userId completion:(receivedArray)completionBlock;

-(void) deleteAddressWithId:(NSInteger) addressId;

//Post Private Mode Settings:
-(void)postDisablePrivateMode:(receivedArray)completionBlock;
-(void)postEnablePrivateMode:(receivedArray)completionBlock;

//Get Requested to Follow Notification:
-(void)getRequestedToFollowNotificationWithPageNumber:(NSInteger) pageNumber completion:(receivedDictionary) completionBlock;

//Post Accept follow request:
-(void)postAcceptFollowRequestWithId:(NSInteger)initiatorId completion:(receivedArray)completionBlock;

//Post Deny follow request:
-(void)postDenyFollowRequestWithId:(NSInteger)initiatorId completion:(receivedArray)completionBlock;

+(void) referFriendWithName:(NSString *) name phoneNumber:(NSString *) phoneNumber email:(NSString *) email completion:(receivedDictionary) completionBlock;

+(void) getReferralCodeCompletion:(receivedDictionary) completionBlock;

//Post Refount an Image:
-(void)postRefountMediaWithMediaId:(NSInteger)mediaId completion:(receivedArray)completionBlock;

//Get Refount Users' Information
-(void)getRefountUsersWithMediaId:(NSInteger)mediaId pageNumber:(NSInteger)pageNumber completion:(receivedArray) completionBlock;

-(void)getSywUserRegistrerUrl:(receivedArray)completionBlock;

@end
