//
//  BaseProductAttributeModel.m
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//


#import "BaseProductAttributeModel.h"

@implementation BaseProductAttributeModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    if ([dict objectForKey:@"extra_info"]) { self.extraInfo = [dict objectForKey:@"extra_info"];}
    if ([dict objectForKey:@"image"]) { self.image = [dict objectForKey:@"image"];}
    if ([dict objectForKey:@"price"]) { self.price = [dict objectForKey:@"price"];}
    if ([dict objectForKey:@"text"]) { self.text = [dict objectForKey:@"text"];}
    if ([dict objectForKey:@"value"]) { self.value = [dict objectForKey:@"value"];}
}

@end
