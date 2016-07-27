//
//  Product.m
//  Spree
//
//  Created by Rush on 9/17/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "Product.h"
#import "Constants.h"

@implementation Product

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        
        //        NSLog(@"PRODU D:%@", dictionary);
        
        NSDictionary *brandDictionary = [dictionary objectForKey:@"brand"];
        
        if (brandDictionary) {
            self.brand = [[Brand alloc] initWithDictionary:[dictionary objectForKey:@"brand"]];
        }
        self.seller = [[Seller alloc] initWithDictionary:[dictionary objectForKey:@"seller"]];
        
        self.buyURL             = [dictionary objectForKey:@"buyURL"];
        self.productId          = [[dictionary objectForKey:@"id"] integerValue];
        self.productDescription = [dictionary objectForKey:@"description"];
        self.imageUrl           = [dictionary objectForKey:@"imageURL"];
        self.name               = [dictionary objectForKey:@"name"];
        self.price              = [[dictionary objectForKey:@"price"] floatValue];
        self.salePrice          = [[dictionary objectForKey:@"salePrice"] floatValue];
        self.finalPrice         = [[dictionary objectForKey:@"finalPrice"] floatValue];
        self.sale               = [[dictionary objectForKey:@"sale"] integerValue];
        self.creationDate       = [dictionary objectForKey:@"creationDate"];
        //        self.retailPrice = [[dictionary objectForKey:@"retailPrice"] floatValue];
        self.shopperPoints      = [[dictionary objectForKey:@"shopperPoints"] integerValue];
        
        
        self.inStock = [[dictionary objectForKey:@"inStock"] boolValue];
        
        //        NSLog(@"PRODUCT -- NAME:%@ -- INS:%i", self.name, self.inStock);
        
        NSDictionary *productTaggerDictionary = [dictionary objectForKey:@"productTagger"];
        
        //        if ([self.brand.name isEqualToString:@"MANGO"] && self.productId == 1581858) {
        //            NSLog(@"PRICE:%f", self.price);
        //        }
        
        if (productTaggerDictionary) {
            self.productTagger = [[User alloc] initWithDictionary:productTaggerDictionary];
            
            NSInteger myId = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] integerValue];
            
            if (self.productTagger.userId == myId) {
                self.isMine = YES;
            }
        }
        
        NSDictionary *socialActionUserProduct = [dictionary objectForKey:@"socialActionUserProduct"];
        
        if (socialActionUserProduct) {
            self.liked = [[socialActionUserProduct objectForKey:@"liked"] boolValue];
        }
        
        NSDictionary *twoTapData = [dictionary objectForKey:@"twoTapData"];
        if (twoTapData) {
            NSDictionary *sitesdict = twoTapData[@"sites"];
            NSDictionary *cart_dict = [sitesdict objectForKey:[[sitesdict allKeys] objectAtIndex:0]];
            self.shippingOption = [[cart_dict objectForKey:@"shipping_options"] valueForKey:@"cheapest"];
            NSDictionary *addToCart = cart_dict[@"add_to_cart"];
            NSDictionary *dict = [addToCart objectForKey:[[addToCart allKeys] objectAtIndex:0]];
            self.twoTapDictionary = dict;
            self.TTOriginalPrice = [dict objectForKey:@"original_price"];
            self.TTPrice = [dict objectForKey:@"price"];
        }
    }
    return self;
}

-(NSDictionary *)dictionary {
    //Does not have inStock or category
    NSDictionary *dictionaryToReturn = @{
                                         @"seller": [self.seller dictionary],
                                         @"buyURL": self.buyURL,
                                         @"description": self.productDescription,
                                         @"imageURL": self.imageUrl,
                                         @"name": self.name,
                                         @"price": @(self.price),
                                         @"salePrice": @(self.price),
                                         @"finalPrice": @(self.price),
                                         @"sale": @(self.price),
                                         @"id": @(self.productId),
                                         @"creationDate": self.creationDate,
                                         };
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToReturn];
    
    //Brand and product tagger might not always be there
    if (self.brand) {
        [mutableDictionary setObject:[self.brand dictionary] forKey:@"brand"];
    }
    
    if (self.productTagger) {
        [mutableDictionary setObject:[self.productTagger dictionary] forKey:@"productTagger"];
    }
    
    return [mutableDictionary copy];
}

@end
