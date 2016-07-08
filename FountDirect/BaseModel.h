//
//  BaseModel.h
//  Spree
//
//  Created by Rush on 10/29/15.
//  Copyright © 2015 Syw. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseModel : NSObject

-(instancetype) initWithDictionary:(NSDictionary *) dictionary;
-(NSDictionary *) dictionary;

-(instancetype)initWithRequestedFollowDictionary:(NSDictionary *)dictionary;


@end
