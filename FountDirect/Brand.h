//
//  Brand.h
//  Spree
//
//  Created by Rush on 10/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface Brand : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) NSUInteger brandId;

@end
