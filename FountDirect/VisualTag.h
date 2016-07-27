//
//  Tag.h
//  Spree
//
//  Created by Rush on 9/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "Product.h"
#import "User.h"

@interface VisualTag : BaseModel

@property (nonatomic, assign) CGFloat xPosition;
@property (nonatomic, assign) CGFloat yPosition;
@property (nonatomic, assign) NSUInteger visualTagId;
@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, strong) NSMutableArray<Product> *arrayOfProducts;
@property (nonatomic, strong) User *productTagger;

@property (nonatomic, assign) BOOL isMine;

@end
