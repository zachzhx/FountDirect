//
//  HashTag.m
//  Fount
//
//  Created by Rush on 2/26/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "Hashtag.h"
#import "Product.h"
#import "Media.h"

@implementation Hashtag

-(NSMutableArray *)postsArray {
    if (!_postsArray) {
        _postsArray = [[NSMutableArray alloc] init];
    }
    return _postsArray;
}

-(NSMutableArray *)productsArray {
    if (!_productsArray) {
        _productsArray = [[NSMutableArray alloc] init];
    }
    return _productsArray;
}

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        
        self.hashTagId = [[dictionary valueForKeyPath:@"HASHTAG.id"] integerValue];
        self.name = [dictionary valueForKeyPath:@"HASHTAG.name"];
        self.entityName = [dictionary valueForKeyPath:@"HASHTAG.entityName"];
        self.followed = [[dictionary objectForKey:@"HASHTAG_FOLLOW_STATUS"] boolValue];
        self.postCount = [[dictionary objectForKey:@"Count"] integerValue];
        
        self.activityHashTagId = [[dictionary valueForKey:@"id"]integerValue];
        self.activityName = [dictionary valueForKey:@"name"];
        self.activityEntityName = [dictionary valueForKey:@"entityName"];
        
        NSArray *arrayOfProductDictionaries = [dictionary objectForKey:@"PRODUCTS"];
        
        for (NSDictionary *productDictionary in arrayOfProductDictionaries) {
            
//            NSLog(@"p D:%@", productDictionary);
            
            Product *product = [[Product alloc] initWithDictionary:productDictionary];
            
//            NSLog(@"p D:%@", product.imageUrl);
            
            [self.productsArray addObject:product];
        }
        
//        NSLog(@"PROD ARR:%@", self.productsArray);
        
        NSArray *arrayOfMediaDictionaries = [dictionary objectForKey:@"POSTS"];
        
        for (NSDictionary *mediaDictionary in arrayOfMediaDictionaries) {
            
            Media *media = [[Media alloc] initWithDictionary:mediaDictionary];
            
            [self.postsArray addObject:media];
        }
    }
    return self;
}

-(instancetype) initWithSingleHashtagDictionary:(NSDictionary *) dictionary {
    
    self = [super init];
    
    if (self) {
        
        self.hashTagId = [[dictionary valueForKeyPath:@"id"] integerValue];
        self.name = [dictionary valueForKeyPath:@"name"];
        self.postCount = [[dictionary valueForKeyPath:@"postsCount"] integerValue];
        
    }
    return self;
}

@end
