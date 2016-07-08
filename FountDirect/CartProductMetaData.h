//
//  CartProductMetaData.h
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brand.h"
#import "Seller.h"

@interface CartProductMetaData : NSObject

@property(strong,nonatomic)NSString *color,*availability;
@property(strong,nonatomic)NSString *price,*size, *fit, *inseam;
@property(strong,nonatomic)NSString *option1, *option2, *option3, *option4;
@property(strong,nonatomic)NSString *option, *options, *style;
@property (nonatomic, assign) NSUInteger shopperPoints;

+ (NSMutableArray*)getProductMetaData:(NSDictionary*)metaDataDict;
@end