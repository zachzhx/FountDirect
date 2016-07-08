//
//  ProductMetadata.h
//  Fount
//
//  Created by Rush on 4/5/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface ProductMetadata : BaseModel

@property (nonatomic, strong) NSString *availability;
@property (nonatomic, assign) NSInteger productMetadataId;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, strong) NSDictionary *option1Dictionary, *option2Dictionary, *option3Dictionary, *option4Dictionary;
@property (nonatomic, assign) NSUInteger shopperPoints;

@end
