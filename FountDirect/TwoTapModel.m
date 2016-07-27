//
//  TwoTapModel.m
//  Spree
//
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "TwoTapModel.h"

@implementation TwoTapModel

@synthesize option1;



- (void)setupWithDictionary:(NSDictionary*)dict
{
    NSString *str = [[dict objectForKey:@"required_field_names"] objectAtIndex:0];
    NSLog(@"%@",[dict objectForKey:@"required_field_names"]);
    if ([str isEqualToString:@"quantity"] && [[dict objectForKey:@"required_field_names"]count] > 1) {
        str = [[dict objectForKey:@"required_field_names"] objectAtIndex:1];
    }
    
    if ([str isEqualToString:@"fit"]) {
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *fitDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            ProductFitModel *fitModel = [ProductFitModel new];
            [fitModel setValuesFromDictionary:fitDict];
            [tmp addObject:fitModel];
        }
        self.fits = [tmp copy];
    }
    else if ([str isEqualToString:@"color"]) {
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *colorDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            ProductColorModel *colorModel = [ProductColorModel new];
            [colorModel setValuesFromDictionary:colorDict];
            [tmp addObject:colorModel];
        }
        self.colors = [tmp copy];
    }
    else if ([str isEqualToString:@"size"]){
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *sizeDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            ProductSizeModel *sizeModel=[ProductSizeModel new];
            [sizeModel setValuesFromDictionary:sizeDict];
            [tmp addObject:sizeModel];
        }
        self.sizes = [tmp copy];
    }
    else if ([str isEqualToString:@"style"]){
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *sizeDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            BaseProductAttributeModel *styleModel=[ProductSizeModel new];
            [styleModel setValuesFromDictionary:sizeDict];
            [tmp addObject:styleModel];
        }
        self.styles = [tmp copy];
    }
    else if ([str isEqualToString:@"option"] || [str isEqualToString:@"options"]){
        self.option = [ProductOptionModel new];
        [self.option setValuesFromDictionary:[[dict objectForKey:@"required_field_values"] objectForKey:str]];
    }
    else if ([str isEqualToString:@"option 1"]){
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *option1Dict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            ProductOption1Model *option1Model = [ProductOption1Model new];
            [option1Model setValuesFromDictionary:option1Dict];
            [tmp addObject:option1Model];
        }
        self.option1 = [tmp copy];
    }else if ([str isEqualToString:@"flavor"]){
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *flavorDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            ProductFlavorModel *flavorModel = [ProductFlavorModel new];
            [flavorModel setValuesFromDictionary:flavorDict];
            [tmp addObject:flavorModel];
        }
        self.flavor = [tmp copy];
        
    }
    else {
        NSMutableArray *tmp = [NSMutableArray new];
        for (NSDictionary *sizeDict in [[dict objectForKey:@"required_field_values"] objectForKey:str]) {
            BaseProductAttributeModel *sizeModel = [BaseProductAttributeModel new];
            [sizeModel setValuesFromDictionary:sizeDict];
            [tmp addObject:sizeModel];
        }
        //self.options = [tmp copy];
    }
}

@end
