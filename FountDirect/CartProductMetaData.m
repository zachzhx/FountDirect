//
//  CartProductMetaData.m
//  Spree
//
//  Created by Xu Zhang on 10/15/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "CartProductMetaData.h"

@implementation CartProductMetaData
@synthesize color,price,size,availability;

+ (NSMutableArray*)getProductMetaData:(NSDictionary*)metaDataDict {
    
    NSMutableArray *array = [NSMutableArray array];
    
    CartProductMetaData *aMetaData = [[CartProductMetaData alloc] init];
    aMetaData.color = [metaDataDict valueForKey:@"color"];
    aMetaData.price = [metaDataDict valueForKey:@"price"];
    aMetaData.size = [metaDataDict valueForKey:@"size"];
    aMetaData.availability = [metaDataDict valueForKey:@"availability"];
    aMetaData.fit = [metaDataDict valueForKey:@"fit"];
    aMetaData.inseam = [metaDataDict valueForKey:@"inseam"];
    aMetaData.option1 = [metaDataDict valueForKey:@"option1"];
    aMetaData.option2 = [metaDataDict valueForKey:@"option2"];
    aMetaData.option3 = [metaDataDict valueForKey:@"option3"];
    aMetaData.option4 = [metaDataDict valueForKey:@"option4"];
    aMetaData.option = [metaDataDict valueForKey:@"option"];
    aMetaData.options = [metaDataDict valueForKey:@"options"];
    aMetaData.style = [metaDataDict valueForKey:@"style"];
    aMetaData.shopperPoints = [[metaDataDict valueForKey:@"shopperPoints"]integerValue];
    [array addObject:aMetaData];
    // NSLog(@"metadataArray: %@",array);
    return array;
    
}

@end
