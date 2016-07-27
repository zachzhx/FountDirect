//
//  ProductDetail.h
//  Spree
//
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDetail : NSObject
@property(strong,nonatomic)NSDictionary *brandDict,*seller,*category,*twoTapData,*logo,*shipping_options;
@property(strong,nonatomic)NSString *imageURL,*price,*salePrice,*name,*buyURL,*description,*aId,*inStock;

@end
