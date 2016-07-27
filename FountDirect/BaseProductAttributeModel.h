//
//  BaseProductAttributeModel.h
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseProductAttributeModel : NSObject

@property (nonatomic, strong) NSString *extraInfo;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *image;

- (void)setValuesFromDictionary:(NSDictionary *)dict;

@end
