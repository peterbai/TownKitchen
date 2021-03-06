//
//  PopupAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PopupAnimationController.h"
#import <POP.h>

@implementation PopupAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
     UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
     fromView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
     
     UIView *dimmingView = [[UIView alloc] initWithFrame:fromView.bounds];
     dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
     dimmingView.layer.opacity = 0.0;
     
     UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
     toView.frame = CGRectMake(0,
     0,
     CGRectGetWidth(transitionContext.containerView.bounds) - 104.f,
     CGRectGetHeight(transitionContext.containerView.bounds) - 288.f);
     toView.center = CGPointMake(transitionContext.containerView.center.x, -transitionContext.containerView.center.y);
     
     [transitionContext.containerView addSubview:dimmingView];
     [transitionContext.containerView addSubview:toView];
     
     POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
     positionAnimation.toValue = @(transitionContext.containerView.center.y);
     positionAnimation.springBounciness = 10;
     [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
     [transitionContext completeTransition:YES];
     }];
     
     POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
     scaleAnimation.springBounciness = 20;
     scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.4)];
     
     POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
     opacityAnimation.toValue = @(0.4);
     
     [toView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
     [toView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
     [dimmingView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

@end
