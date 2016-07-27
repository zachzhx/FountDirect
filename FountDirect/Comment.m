//
//  Comment.m
//  Fount
//
//  Created by Rush on 6/9/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        
//        self.comment = [dictionary valueForKeyPath:@"commentJson.originalComment"];
//        self.commentId = [[dictionary valueForKeyPath:@"commentJson.id"] integerValue];
//        self.relativeTime = [dictionary valueForKeyPath:@"commentJson.relativeTime"];
//        self.user = [[User alloc] initWithDictionary:[dictionary valueForKeyPath:@"userJson"]];
        
        self.comment = [dictionary valueForKeyPath:@"originalComment"];
        self.commentId = [[dictionary valueForKeyPath:@"id"] integerValue];
        self.relativeTime = [dictionary valueForKeyPath:@"relativeTime"];
        
//        self.user = [[User alloc] initWithDictionary:[dictionary valueForKeyPath:@"userJson"]];
//        self.metadataMapsDictionary = [dictionary objectForKey:@"metadataMaps"];
    }
    return self;
}

@end
