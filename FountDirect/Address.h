//
//  Address.h
//  Spree
//
//  Created by Rush on 11/5/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "User.h"

@interface Address : BaseModel

@property (nonatomic, strong) NSString *line1;
@property (nonatomic, strong) NSString *line2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSString *zip;

@property (nonatomic, assign) NSInteger addressId;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) User *user;

-(instancetype)initWithAddressLine1:(NSString *) addressLine1 name:(NSString *) name city:(NSString *) city state:(NSString *) state zip:(NSString *) zip phoneNumber:(NSString *) phoneNumber type:(NSString *) type;

-(NSDictionary *) dictionary;

@end
