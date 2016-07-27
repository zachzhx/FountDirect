//
//  ProductFitModel.h
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseProductAttributeModel.h"

@interface ProductFitModel : BaseProductAttributeModel

@property (strong, nonatomic) NSArray *colors;

@property (strong, nonatomic) NSArray *sizes;

@property (strong, nonatomic) NSArray *inseam;
@property (strong, nonatomic) NSString *aFitText;



@end
