//
//  TwoTapModel.h
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductFitModel.h"
#import "ProductColorModel.h"
#import "ProductOptionModel.h"
#import "ProductSizeModel.h"
#import "ProductOption1Model.h"
#import "ProductStyleModel.h"
#import "ProductFlavorModel.h"

@interface TwoTapModel : NSObject

@property (strong, nonatomic) NSArray *fits;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *sizes;
@property (strong, nonatomic) NSArray *styles;

@property (strong, nonatomic) NSArray *option1;
@property (strong, nonatomic) ProductOptionModel *option;

@property (strong, nonatomic) NSArray *flavor;

- (void)setupWithDictionary:(NSDictionary*)dict;

@end
