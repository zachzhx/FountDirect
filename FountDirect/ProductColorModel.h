//
//  ProductColorModel.h
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseProductAttributeModel.h"

@interface ProductColorModel : BaseProductAttributeModel

@property (strong, nonatomic) NSArray *sizes;

@property (strong, nonatomic) NSArray *styles;

@property (strong, nonatomic) NSArray *inseam;

@end
