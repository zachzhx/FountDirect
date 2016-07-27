//
//  Notification.h
//  Fount
//
//  Created by Rush on 4/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

#import "Media.h"
#import "Product.h"
#import "User.h"
#import "Order.h"
#import "Comment.h"
//#import "Brand.h"
//#import "Seller.h"

@interface Notification : BaseModel

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) User *firstUser, *secondUser;
@property (nonatomic, strong) Order *order;
@property (nonatomic, strong) Comment *comment;
@property (nonatomic, strong) NSDictionary *metadataDictionary;
//@property (nonatomic, strong) Brand *brand;
//@property (nonatomic, strong) Seller *seller;

@property (nonatomic, strong) NSArray *arrayOfMedia;
@property (nonatomic, strong) NSArray *arrayOfproducts;

@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, assign) NSInteger notificationId;
@property (nonatomic, strong) NSString *notificationType;

//@property (nonatomic, strong) NSString *likeEntityType;
//@property (nonatomic, strong) NSString *followEntityType;

@property (nonatomic, assign) BOOL isFollowing, isPendingApproval;

@end
