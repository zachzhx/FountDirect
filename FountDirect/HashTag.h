//
//  HashTag.h
//  Fount
//
//  Created by Rush on 2/26/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface Hashtag : BaseModel

@property (nonatomic, assign) NSInteger hashTagId;
@property (nonatomic, strong) NSString *name, *entityName;
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, strong) NSMutableArray *postsArray, *productsArray;
@property (nonatomic, assign) NSInteger postCount;

@property (nonatomic, assign) NSInteger activityHashTagId;
@property (nonatomic, strong) NSString *activityName, *activityEntityName;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(instancetype)initWithSingleHashtagDictionary:(NSDictionary *)dictionary;

@end
