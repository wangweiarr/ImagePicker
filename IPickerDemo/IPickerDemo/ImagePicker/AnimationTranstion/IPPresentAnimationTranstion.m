//
//  IPPresentAnimationTranstion.m
//  IPickerDemo
//
//  Created by wangjianlong on 2018/6/2.
//  Copyright © 2018年 JL. All rights reserved.
//

#import "IPPresentAnimationTranstion.h"
#import "IPImageReaderViewController.h"
#import "UICollectionViewCell+PhotoReader.h"
#import "IPickerViewController.h"
#import "IPAssetModel.h"
#import "IPAssetManager.h"
#import "IPickerViewController+AnimationTranstion.h"

@interface IPickerViewController ()

- (UICollectionView *)mainView;
- (NSMutableArray *)curImageModelArr;
@end

@interface IPPresentAnimationTranstion () 

@property (nonatomic, strong) UIImageView *animateImageView;

@end

@implementation IPPresentAnimationTranstion

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromController.view;
    UIView *toView = toController.view;
    
    //入场动效
    if (toController.isBeingPresented) {
        [containerView addSubview:toView];
        [self inAnimation_moveWithContext:transitionContext containerView:containerView toView:toView];
    }
    
    //出场动效
    if (fromController.isBeingDismissed) {
        [self outAnimation_moveWithContext:transitionContext containerView:containerView fromView:fromView];
    }
}

#pragma mark private

- (void)completeTransition:(id <UIViewControllerContextTransitioning>)transitionContext isIn:(BOOL)isIn {
    if (_animateImageView && _animateImageView.superview) [_animateImageView removeFromSuperview];

    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}


#pragma mark animation -- move

- (void)inAnimation_moveWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView toView:(UIView *)toView {
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([fromController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *fromNav = (UINavigationController *)fromController;
        fromController = fromNav.topViewController;
    }
    
    
    IPickerViewController *picker = (IPickerViewController *)fromController;
    NSUInteger index = picker.selectIndex;
    UICollectionViewCell *cell = [picker.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    CGRect fromFrame = CGRectZero;
    fromFrame = cell.sourceImageView ? [self getFrameInWindowWithView:cell.sourceImageView] : CGRectZero;
    
    __block CGRect toFrame = CGRectZero;
    IPAssetModel *model = picker.curImageModelArr[picker.selectIndex];
    [[IPAssetManager defaultAssetManager] getFullScreenImageWithMutipleAsset:model.asset photoWidth:[IPPresentAnimationTranstion currentDisplayWindow].bounds.size completion:^(UIImage *image, NSDictionary *info) {
        
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            CGFloat height = [IPPresentAnimationTranstion currentDisplayWindow].bounds.size.height;
            CGFloat width = height * image.size.width /image.size.height;
            toFrame.size = CGSizeMake(width, height);
        }else {
            CGFloat width = [IPPresentAnimationTranstion currentDisplayWindow].bounds.size.width;
            CGFloat height = width * image.size.height /image.size.width;
            toFrame.size = CGSizeMake(width, height);
        }
        toFrame.origin = CGPointZero;
        
        [containerView addSubview:toView];
        self.animateImageView.image = image;
        self.animateImageView.frame = fromFrame;
        [containerView addSubview:self.animateImageView];
        
        toView.alpha = 0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1;
            self.animateImageView.frame = toFrame;
        } completion:^(BOOL finished) {
            [self completeTransition:transitionContext isIn:YES];
        }];
    }];
    
}

- (void)outAnimation_moveWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView fromView:(UIView *)fromView {
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([toController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *toNav = (UINavigationController *)toController;
        toController = toNav.topViewController;
    }
    
    
    IPickerViewController *picker = (IPickerViewController *)toController;
    NSUInteger index = [picker realIndexFromPhotoReaderCurrentIndex:fromController.currentPage];
    UICollectionViewCell *toCell = [picker.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    CGRect toFrame = [self getFrameInWindowWithView:toCell];
    
    UICollectionViewCell *cell = [fromController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromController.currentPage inSection:0]];
    UIImageView *fromImageView = cell.animateImageView.superview ? cell.animateImageView : cell.sourceImageView;
    
    self.animateImageView.image = fromImageView.image;
    self.animateImageView.frame = [self getFrameInWindowWithView:fromImageView];
    [containerView addSubview:self.animateImageView];
    
    fromImageView.hidden = YES;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.alpha = 0;
        self.animateImageView.frame = toFrame;
        cell.animateImageView.frame = toFrame;
    } completion:^(BOOL finished) {
        
        [cell.animateImageView removeFromSuperview];
        [self completeTransition:transitionContext isIn:NO];
    }];
    
}


+ (UIWindow *)currentDisplayWindow {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                window = temp;
                break;
            }
        }
    }
    return window;
}

//拿到 view 基于屏幕的 frame
- (CGRect)getFrameInWindowWithView:(UIView *)view {
    return view ? [view convertRect:view.bounds toView:[IPPresentAnimationTranstion currentDisplayWindow]] : CGRectZero;
}


#pragma mark getter

- (UIImageView *)animateImageView {
    if (!_animateImageView) {
        _animateImageView = [UIImageView new];
        _animateImageView.contentMode = UIViewContentModeScaleAspectFill;
        _animateImageView.layer.masksToBounds = YES;
    }
    return _animateImageView;
}

@end
