//
//  BounceAnimationController.h
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftEntranceAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

-(instancetype) initWithPresentationBool:(BOOL) isPresenting;

@end