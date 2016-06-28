//
//  Constants.h
//  Spree
//
//  Created by Rush on 9/11/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#ifndef Spree_Constants_h
#define Spree_Constants_h

//#define WEB_DOMAIN @"http://hfdvsywmkweb1.intra.searshc.com:13080/lifestyle"
//#define WEB_DOMAIN @"https://spreeqa.searshc.com/lifestyle"
//#define WEB_DOMAIN @"http://spree.searshc.com/lifestyle"
//#define WEB_DOMAIN @"http://10.28.141.119:9090"
//#define WEB_DOMAIN @"http://lifestyleqa.shopyourway.com/lifestyle"
//#define WEB_DOMAIN @"http://trprsywmkapp1.intra.searshc.com:8780/lifestyle"
#define WEB_DOMAIN @"https://fountit.com/lifestyle"
//#define WEB_DOMAIN @"https://spreest.searshc.com/lifestyle"
//#define WEB_DOMAIN @"http://localhost:9090"
//#define WEB_DOMAIN @"https://mktgspreest.searshc.com/lifestyle"
//#define WEB_DOMAIN @"trstsywlfsapp01.vm.itg.corp.us.shldcorp.com:8543/lifestyle"
//#define WEB_DOMAIN @"https://hfqasywlfsapp01.vm.itg.corp.us.shldcorp.com:8543/lifestyle"

//#define WEB_DOMAIN @"http://10.28.166.53:9090"

//#define exclusionArray @[@(1),@(2),@(3)]

//#define kIsLoggedInKey  @"isLoggedInKey"
#define kUserIdKey      @"userIdKey"
#define kDisplayNameKey @"displayNameKey"
#define kDeviceTokenKey @"deviceTokenKey"
#define kEmailKey       @"emailKey"
#define kConfirmedKey   @"confirmedKey"
#define kShouldDisplayBannerKey   @"shouldDisplayBannerKey"
#define kRegisteredOpenEmailKey   @"registeredOpenEmailKey"
#define kIsSywConnected @"isSywConnected"

#define kViewAllCommentsStringIdentifier @"viewAllComments"

#define kNumberOfItemsInCartKey @"numberOfItemsInCartKey"
#define kSessionKey @"sessionKey"

#define kTouchIDCheckedKey @"touchIDCheckedKey"

#define kCheckBoxCheckedKey @"checkBoxCheckedKey"
#define kLoginKeychainService @"com.syw.spree.Login"
#define kTouchIDCheckedKey @"touchIDCheckedKey"

#define kInstagramProfilePictureStringKey @"profilePictureKey"

#define kInstagramIdKey @"instagramIdKey"

#define kStatusBarAndNavigationheight 64

//Entity Names
#define kBrandEntityName @"BrandJson"
#define kUserEntityName @"UserJson"
#define kSellerEntityName @"SellerEntity"

//sortBy
#define kSortByRelevancy    @"relevancy"
#define kSortByLowToHigh    @"price_low_to_high"
#define kSortByHighToLow    @"price_high_to_low"
#define kSortByNewArrivals  @"arrival"

#define kPhoneNumberTextFieldTag 100

//Push Notifications
#define kPushNotificationName @"pushNotificationReceived"
#define kPushAppActiveNotificationName @"pushNotificationAppActive"

#define kDeepLink @"deepLink"
#define kDeepLinkSelectDiscover @"goToDiscover"

//Activity EntityTypes
#define kLikeEntityTypeProduct  @"PRODUCT"
#define kLikeEntityTypeMedia    @"MEDIA"

#define kFollowEntityTypeBrand  @"BRAND"
#define kFollowEntityTypeUser   @"User"
#define kFollowEntityTypeSeller @"SELLER"
#define KFollowEntityTypeHashtag @"HASHTAG"

#define kActivityTypeFollow     @"FOLLOW"
#define kActivityTypeImport     @"IMPORT"
#define kActivityTypeLike       @"LIKE"
#define kActivityTypeMedia      @"PRODUCTS_TAGGED_IN_MEDIA"
#define kActivityTypeVT         @"PRODUCTS_TAGGED_IN_VT"

//Google Analytics
#define kDiscoverPageName       @"Discover Screen"
#define kShopPageName           @"Shop Screen"
#define kImportPageName         @"Import Screen"
#define kAlertsPageName         @"Alerts Screen"
#define kProfilePageName        @"Private Profile Screen"
#define kThankYouPageName       @"Thank You Screen"
#define kSettingsPageName       @"Settings Screen"

#define kShoppingCartPageName   @"Shopping Cart Screen"
#define kProductDetailPageName  @"Product Detail Screen"
#define kMediaDetailPageName    @"Media Detail Screen"
#define kTagSearchPageName      @"Tag Search Screen"
#define kShopSearchPageName     @"Shop Search Screen"
#define kShippingPageName       @"Shipping Screen"
#define kPaymentPageName        @"Payment Screen"
#define kConfirmOrderPageName   @"Confirm Order Screen"

#define kActivityPageName       @"Activity Screen"
#define kNotificationsPageName  @"Notifications Screen"

#define kSelectColorAndSizePageName @"SelectColorAndSize Screen"

#define kProductSearchPageName @"Product Search Screen"
#define kBrandSearchPageName  @"Brand Search Screen"
#define kSellerSearchPageName  @"Seller Search Screen"
#define kPeopleSearchPageName  @"People Search Screen"
#define kHashtagSearchPageName @"Hashtag Search Screen"

//Event Categories
#define kEventCategoryAddToCart  @"Add To Cart"

#define kEventCategoryDiscoverToMDP @"Discover To MDP"
#define kEventCategoryCarouselToPDP @"Carousel To PDP"
#define kEventCategoryPlacingOrder  @"Place Order"
#define kEventCategoryAddTag        @"Add Tag To Media"

#define kEventCategoryDiscoverToPublicProfile  @"Discover To Public Profile"

//Event Actions
#define kEventActionAddToCart  @"Add To Cart Clicked"
#define kEventActionMediaClicked  @"Media Clicked"

#define kEventActionPlaceOrderClicked  @"Place Order Clicked"
#define kEventActionAddTagClicked  @"Add Tag Clicked"

#define kEventActionCarouselProductClicked  @"Carousel Product Clicked"
#define kEventActionDiscoverProfileClicked  @"Discover Profile Clicked"

//Event Labels
#define kEventLabelAddingToCart     @"Adding to Cart"
#define kEventLabelGoingToWeb       @"Going to Web"

#define kEventLabelGoingToOptionsSelection    @"Going to Options Selection"

#define kPrice0To25      @"0.0-25.0"
#define kPrice25To50     @"25.0-50.0"
#define kPrice50To100    @"50.0-100.0"
#define kPrice100To150   @"100.0-150.0"
#define kPrice150To250   @"150.0-250.0"
#define kPrice250To500   @"250.0-500.0"
#define kPrice500To1000  @"500.0-1000.0"
#define kPrice1000To2500 @"1000.0-2500.0"

#define kSaleAll        @"1.0-100.0"
#define kSale20Percent  @"20.0-100.0"
#define kSale30Percent  @"30.0-100.0"
#define kSale40Percent  @"40.0-100.0"
#define kSale50Percent  @"50.0-100.0"
#define kSale60Percent  @"60.0-100.0"
#define kSale70Percent  @"70.0-100.0"

#endif
