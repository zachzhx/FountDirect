//
//  CartProductModel.h
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartProductModel : NSObject
@property(strong,nonatomic)NSString *name,*aId,*aPrice,*aSalePrice,*aFinalPrice,*aRetailPrice,*aDescription;
@property (nonatomic, assign) BOOL inStock;
@property(strong,nonatomic) NSString *imageURL;
@property(strong,nonatomic) NSDictionary *seller,*category,*brand;

+ (NSMutableArray*)getCartProduct:(NSDictionary*)dataDict;

@property (nonatomic, assign) NSUInteger shopperPoints;

@end
