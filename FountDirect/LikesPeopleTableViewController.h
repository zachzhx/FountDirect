//
//  LikesPeopleTableViewController.h
//  Fount
//
//  Created by Xu Zhang on 12/22/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface LikesPeopleTableViewController : UITableViewController
@property (strong,nonatomic) NSMutableArray *likesPeopleInfoArray;
@property (strong,nonatomic) NSMutableArray *instagramPeopleInfoArray;
@property (strong,nonatomic)  Media *media;
@property (strong,nonatomic) NSString *productId;

@property (nonatomic, assign) BOOL fromPush;
@property (nonatomic, assign) BOOL fromRefountUsers;
//@property (strong,nonatomic) NSMutableArray *refountUserActionArray;
@property (strong,nonatomic) NSMutableDictionary *refountUserActionDictionary;

@end
