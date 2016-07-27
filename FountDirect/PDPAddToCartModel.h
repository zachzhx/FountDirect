//
//  PDPAddToCartModel.h
//  Spree
//
//  Created by Xu Zhang on 11/10/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PDPAddToCartModel : NSObject
@property(strong,nonatomic)NSString *userId,*productId,*productMetadata_productId,*mediaId,*visualTagId;
@property(strong,nonatomic)NSString *productMetadata_option,*productMetadata_fit,*productMetadata_color,*productMetadata_size,*productMetadata_options,*productMetadata_inseam,*productMetadata_style,*productMetadata_option1,*productMetadata_option2,*productMetadata_option3,*productMetadata_option4;
@property(strong,nonatomic)NSString  *productMetadata_availability,*quantity,*shippingMethod,*originalUrl;
@property (nonatomic, strong) NSString* price;

@end