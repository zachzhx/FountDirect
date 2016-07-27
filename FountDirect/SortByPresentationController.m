//
//  RoundRectPresentationController.m
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import "SortByPresentationController.h"

@interface SortByPresentationController ()

@property (nonatomic, readonly) UIView *dimmingView;

@end

@implementation SortByPresentationController

-(UIView *)dimmingView {
    static UIView *instance = nil;
    if (instance == nil) {
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    return instance;
}

- (void)presentationTransitionWillBegin {
    
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
//    if (!completed) {
//        [self.dimmingView removeFromSuperview];
//    }
}

- (void)dismissalTransitionWillBegin {
//    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        self.dimmingView.alpha = 0;
//    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
//    if (completed) {
//        [self.dimmingView removeFromSuperview];
//    }
}

- (CGRect)frameOfPresentedViewInContainerView {
//    CGFloat yPos = 0;
    
//    CGRect frame = CGRectMake(self.presentedView.frame.origin.x, yPos, self.frameSize.width / 2, self.frameSize.height - yPos);
    CGRect frame = CGRectMake(0, 0, self.frameSize.width, self.frameSize.height);
    
    return frame;
}

- (void)containerViewWillLayoutSubviews {
//    self.dimmingView.frame = self.containerView.bounds;
//    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

@end
