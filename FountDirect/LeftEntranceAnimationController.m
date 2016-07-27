//
//  BounceAnimationController.m
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import "LeftEntranceAnimationController.h"

@interface LeftEntranceAnimationController()

@property (nonatomic, assign) BOOL isPresenting;

@end

@implementation LeftEntranceAnimationController

- (instancetype)initWithPresentationBool:(BOOL) isPresenting {
    
    self = [super init];
    if (self) {
        self.isPresenting = isPresenting;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isPresenting) {
        [self animatePresentationWithTransitionContext:transitionContext];
    } else {
        [self animateDismissalWithTransitionContext:transitionContext];
    }
    
}

-(void) animatePresentationWithTransitionContext:(id <UIViewControllerContextTransitioning>) transitionContext {
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect endFrame = [transitionContext finalFrameForViewController:toViewController];
    
    CGRect startFrame = endFrame;
    startFrame.origin.x -= toView.frame.size.width;
    
    toView.frame = startFrame;
    
    [containerView addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.frame = endFrame;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

-(void) animateDismissalWithTransitionContext:(id <UIViewControllerContextTransitioning>) transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIView *containerView = [transitionContext containerView];
    
    CGRect endFrame = [transitionContext finalFrameForViewController:fromViewController];

    CGRect startFrame = endFrame;
    startFrame.origin.x -= fromViewController.view.frame.size.width;

//    toView.frame = startFrame;
//    
//    [containerView addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.frame = startFrame;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

@end
