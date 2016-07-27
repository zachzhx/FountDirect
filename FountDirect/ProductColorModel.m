//
//  ProductColorModel.m
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "ProductColorModel.h"
#import "ProductSizeModel.h"

@implementation ProductColorModel

- (void)setValuesFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *tmpArr = [NSMutableArray new];
    [super setValuesFromDictionary:dict];
    
    NSArray *checkArr = [[[dict objectForKey:@"dep"] objectForKey:@"size"] valueForKey:@"dep"];
    
    if ([[dict objectForKey:@"dep"] objectForKey:@"size"]){
        if ([[checkArr objectAtIndex:0] count] != 0) {
            for (NSDictionary *sizeDict in [[dict objectForKey:@"dep"] objectForKey:@"size"]){
                ProductSizeModel *sizeModel = [ProductSizeModel new];
                [sizeModel setValuesFromDictionary:sizeDict];
                [tmpArr addObject:sizeModel];
                
                self.extraInfo = [dict objectForKey:@"extra_info"];
                self.image = [dict objectForKey:@"image"];
                self.price = [dict objectForKey:@"price"];
                self.text = [dict objectForKey:@"text"];
                self.value = [dict objectForKey:@"value"];
            }
            self.sizes = [tmpArr copy];
        }else{
            for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"size"]) {
                BaseProductAttributeModel *sizeModel = [ProductColorModel new];
                [sizeModel setValuesFromDictionary:colorDict];
                [tmpArr addObject:sizeModel];
            }
            self.sizes = [tmpArr copy];
        }
    }else{
        for (NSDictionary *colorDict in [[dict objectForKey:@"dep"] objectForKey:@"style"]) {
            BaseProductAttributeModel *styleModel = [ProductColorModel new];
            [styleModel setValuesFromDictionary:colorDict];
            [tmpArr addObject:styleModel];
        }
        self.styles = [tmpArr copy];
    }
}

@end
