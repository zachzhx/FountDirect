//
//  ProductOption1Model.h
//  Spree
//
//  Created by Xu Zhang on 11/11/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseProductAttributeModel.h"

@interface ProductOption1Model : BaseProductAttributeModel

@property (strong, nonatomic) NSMutableArray *subOptions;
@property (assign, nonatomic) NSInteger numberOfOptions;

@end
