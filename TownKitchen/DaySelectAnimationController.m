//
//  DaySelectAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectAnimationController.h"
#import "TKHeader.h"
#import "DayCell.h"
#import <FXBlurView.h>

CGFloat const transitionImageInitialHeight = 130;
CGFloat const transitionImageFinalHeight = 200;
CGFloat const transitionImageYPositionAdjustment = 99.0;

@interface DaySelectAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation DaySelectAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];

    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, self.fromViewController.view.frame.size.width, 64)];
    
    // Define snapshot frame
    CGRect selectedCellFrame = self.selectedCell.frame;
    selectedCellFrame.origin.y += (self.contentOffset.y + header.frame.size.height);

    // Create transition view with same frame as toVC's image
    CGFloat imageCenterYDelta = transitionImageFinalHeight / 2 - selectedCellFrame.size.height / 2;
    UIView *transitionView = [[UIView alloc] initWithFrame:CGRectMake(selectedCellFrame.origin.x,
                                                                      selectedCellFrame.origin.y - imageCenterYDelta,
                                                                      selectedCellFrame.size.width,
                                                                      transitionImageFinalHeight)];
    
    UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:transitionView.bounds];
    transitionImageView.image = [(DayCell *)self.selectedCell blurredImage];
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.clipsToBounds = YES;
    [transitionView addSubview:transitionImageView];
    [self.containerView addSubview:transitionView];
    
    // Snapshot cells above selected cell
    UIImageView *aboveCellsImageView = [self imageViewFromCellsAboveSelectedCellFrame:selectedCellFrame];
    [self.containerView addSubview:aboveCellsImageView];
    
    // Snapshot cells below selected cell
    UIImageView *belowCellsImageView = [self imageViewFromCellsBelowSelectedCellFrame:selectedCellFrame];
    [self.containerView addSubview:belowCellsImageView];
    
    // Hide the original tableview
    self.fromViewController.view.hidden = YES;
    
    // Set initial frames
    CGRect initialToFrame = self.toViewController.view.frame;
    self.toViewController.view.frame = CGRectMake(initialToFrame.origin.x, selectedCellFrame.origin.y - transitionImageYPositionAdjustment, initialToFrame.size.width, initialToFrame.size.height);
    
    // Define final frames
    CGRect finalToFrame = [transitionContext finalFrameForViewController:self.toViewController];
    CGRect finalTransitionImageFrame = CGRectMake(selectedCellFrame.origin.x, header.frame.size.height, selectedCellFrame.size.width, transitionImageFinalHeight);

    [self.containerView addSubview:header];
    
    // Animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         aboveCellsImageView.center = CGPointMake(aboveCellsImageView.center.x, aboveCellsImageView.center.y - aboveCellsImageView.frame.size.height + header.frame.size.height);
                         belowCellsImageView.center = CGPointMake(belowCellsImageView.center.x, belowCellsImageView.center.y + belowCellsImageView.frame.size.height);

                         transitionView.frame = finalTransitionImageFrame;
                         transitionView.alpha = 0;
                         
                         self.toViewController.view.frame = finalToFrame;

                     }
                     completion:^(BOOL finished) {
                         self.fromViewController.view.hidden = NO;
                         [transitionContext completeTransition:YES];
                     }];
}

#pragma mark - Helper Methods


- (UIImageView *)imageViewFromSelectedCellFrame:(CGRect)selectedCellFrame {
    UIImageView *selectedCellImageView = [[UIImageView alloc] initWithFrame:selectedCellFrame];
    selectedCellImageView.image = [self imageInRect:selectedCellFrame fromView:self.toViewController.view];
    return selectedCellImageView;
}

- (UIImageView *)imageViewFromCellsAboveSelectedCellFrame:(CGRect)selectedCellFrame {
    CGFloat distanceAboveSelectedCell = fmaxf(0, selectedCellFrame.origin.y);
    CGRect aboveCellsFrame = CGRectMake(0, 0, self.fromViewController.view.frame.size.width, distanceAboveSelectedCell);
    UIImageView *aboveCellsImageView = [[UIImageView alloc] initWithFrame:aboveCellsFrame];
    aboveCellsImageView.image = [self imageInRect:aboveCellsFrame fromView:self.fromViewController.view];
    return aboveCellsImageView;
}

- (UIImageView *)imageViewFromCellsBelowSelectedCellFrame:(CGRect)selectedCellFrame {
    CGFloat yPositionOfSelectedCellBottomEdge = selectedCellFrame.origin.y + selectedCellFrame.size.height;
    CGFloat distanceBelowSelectedCell =
        fmaxf(0, self.fromViewController.view.frame.size.height - yPositionOfSelectedCellBottomEdge);
    CGRect belowCellsFrame = CGRectMake(0, yPositionOfSelectedCellBottomEdge, self.fromViewController.view.frame.size.width, distanceBelowSelectedCell);
    UIImageView *belowCellsImageView = [[UIImageView alloc] initWithFrame:belowCellsFrame];
    belowCellsImageView.image = [self imageInRect:belowCellsFrame fromView:self.fromViewController.view];
    return belowCellsImageView;
}

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.bounds.size.width, view.bounds.size.height), view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageInRect:(CGRect)rect fromView:(UIView *)view {
    UIImage *viewImage = [self imageFromView:view];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGImageRef image = CGImageCreateWithImageInRect(viewImage.CGImage, CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale));
    UIImage *imageInRect = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return imageInRect;
}

@end