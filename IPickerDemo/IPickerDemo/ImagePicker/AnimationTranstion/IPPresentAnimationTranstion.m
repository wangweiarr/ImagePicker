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

@interface IPPresentAnimationTranstion () {
//    __weak YBImageBrowser *browser;
}

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
        switch (fromView.tag) {
            case 0: {
                [self inAnimation_moveWithContext:transitionContext containerView:containerView toView:toView];
            }
                break;
            case 1: {
                [self inAnimation_fadeWithContext:transitionContext containerView:containerView toView:toView];
            }
                break;
            default:
                [self inAnimation_noWithContext:transitionContext];
                break;
        }
    }
    
    //出场动效
    if (fromController.isBeingDismissed) {
        switch (toView.tag) {
            case 0: {
                [self outAnimation_moveWithContext:transitionContext containerView:containerView fromView:fromView];
            }
                break;
            case 1: {
                [self outAnimation_fadeWithContext:transitionContext containerView:containerView fromView:fromView];
            }
                break;
            default:
                [self outAnimation_noWithContext:transitionContext];
                break;
        }
    }
}

#pragma mark private

- (void)completeTransition:(id <UIViewControllerContextTransitioning>)transitionContext isIn:(BOOL)isIn {
    if (_animateImageView && _animateImageView.superview) [_animateImageView removeFromSuperview];
//    if (isIn && !YBImageBrowser.isControllerPreferredForStatusBar)  [[UIApplication sharedApplication] setStatusBarHidden:!YBImageBrowser.showStatusBar];
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

#pragma mark animation -- no

- (void)inAnimation_noWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self completeTransition:transitionContext isIn:YES];
}

- (void)outAnimation_noWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
   
    UIImageView *fromImageView = [self getCurrentImageViewFromBrowser:fromController];
    if (fromImageView) fromImageView.hidden = YES;
    [self completeTransition:transitionContext isIn:NO];
}

#pragma mark animation -- fade

- (void)inAnimation_fadeWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView toView:(UIView *)toView {
    
    __block UIImage *image = nil;
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [self in_getShowInfoFromBrowser:fromController complete:^(CGRect _fromFrame, UIImage *_fromImage) {
        image = _fromImage;
    }];
    if (!image) {
        [self completeTransition:transitionContext isIn:YES];
        return;
    }
    __block CGRect toFrame = CGRectZero;
//    [YBImageBrowserCell countWithContainerSize:containerView.bounds.size image:image screenOrientation:browser.so_screenOrientation verticalFillType:browser.verticalScreenImageViewFillType horizontalFillType:browser.horizontalScreenImageViewFillType completed:^(CGRect imageFrame, CGSize contentSize, CGFloat minimumZoomScale, CGFloat maximumZoomScale) {
//        toFrame = imageFrame;
//    }];
    
    self.animateImageView.image = image;
    self.animateImageView.frame = toFrame;
    [containerView addSubview:self.animateImageView];
    toView.alpha = 0;
    self.animateImageView.alpha = 0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.alpha = 1;
        self.animateImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [self completeTransition:transitionContext isIn:YES];
    }];
}

- (void)outAnimation_fadeWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView fromView:(UIView *)fromView {
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIImageView *fromImageView = [self getCurrentImageViewFromBrowser:fromController];
    if (!fromImageView) {
        [self completeTransition:transitionContext isIn:NO];
        return;
    }
    
    self.animateImageView.image = fromImageView.image;
    self.animateImageView.frame = [self getFrameInWindowWithView:fromImageView];
    [containerView addSubview:self.animateImageView];
    
    fromView.alpha = 1;
    self.animateImageView.alpha = 1;
    //因为可能是拖拽动画的视图，索性隐藏掉
    fromImageView.hidden = YES;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.alpha = 0;
        self.animateImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self completeTransition:transitionContext isIn:NO];
    }];
}


#pragma mark animation -- move

- (void)inAnimation_moveWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView toView:(UIView *)toView {
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    __block CGRect fromFrame = CGRectZero;
    __block UIImage *image = nil;
    [self in_getShowInfoFromBrowser:fromController complete:^(CGRect _fromFrame, UIImage *_fromImage) {
        fromFrame = _fromFrame;
        image = _fromImage;
    }];
    if (CGRectEqualToRect(fromFrame, CGRectZero) || !image) {
        [self inAnimation_fadeWithContext:transitionContext containerView:containerView toView:toView];
        return;
    }
    __block CGRect toFrame = CGRectZero;
//    [YBImageBrowserCell countWithContainerSize:containerView.bounds.size image:image screenOrientation:browser.so_screenOrientation verticalFillType:browser.verticalScreenImageViewFillType horizontalFillType:browser.horizontalScreenImageViewFillType completed:^(CGRect imageFrame, CGSize contentSize, CGFloat minimumZoomScale, CGFloat maximumZoomScale) {
//        toFrame = imageFrame;
//    }];
    
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
}

- (void)outAnimation_moveWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView fromView:(UIView *)fromView {
    IPImageReaderViewController *fromController = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect toFrame = [self getFrameInWindowWithView:[self getCurrentImageViewFromBrowser:fromController]];
    UIImageView *fromImageView = [self getCurrentImageViewFromBrowser:fromController];
    if (CGRectEqualToRect(toFrame, CGRectZero) || !fromImageView) {
        [self outAnimation_fadeWithContext:transitionContext containerView:containerView fromView:fromView];
        return;
    }
    
    self.animateImageView.image = fromImageView.image;
    self.animateImageView.frame = [self getFrameInWindowWithView:fromImageView];
    [containerView addSubview:self.animateImageView];
    
    fromImageView.hidden = YES;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.alpha = 0;
        self.animateImageView.frame = toFrame;
    } completion:^(BOOL finished) {
        [self completeTransition:transitionContext isIn:NO];
    }];
    
}

#pragma mark public


#pragma mark get info from browser

//从图片浏览器拿到初始化过后首先显示的数据
- (BOOL)in_getShowInfoFromBrowser:(IPImageReaderViewController *)browser complete:(void(^)(CGRect fromFrame, UIImage *fromImage))complete {
    
    CGRect _fromFrame = CGRectZero;
    UIImage *_fromImage = nil;
    
    NSArray *models = browser.dataArr;
    NSUInteger index = browser.currentPage;
    UICollectionViewCell *cell = [browser.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (models && models.count > browser.currentPage) {
        
        _fromFrame = cell.animateImageView ? [self getFrameInWindowWithView:cell.animateImageView] : CGRectZero;
        _fromImage = cell.animateImageView.image;
        
    }
     else {
        NSLog(@"you must perform selector(setDataArray:) or implementation protocol(dataSource) of YBImageBrowser to configuration data For user interface");
        return NO;
    }
    
    if (complete) complete(_fromFrame, _fromImage);
    return YES;
}


//拿到 view 基于屏幕的 frame
- (CGRect)getFrameInWindowWithView:(UIView *)view {
    return view ? [view convertRect:view.bounds toView:[UIApplication sharedApplication].keyWindow] : CGRectZero;
}

//从图片浏览器拿到当前显示的 imageView （若是手势动画请求的隐藏，应该做动画视图的效果）
- (UIImageView *)getCurrentImageViewFromBrowser:(IPImageReaderViewController *)browser
{
    UICollectionViewCell *cell = [self getCurrentCellFromBrowser:browser];
    if (!cell) return nil;
    return cell.sourceImageView;
}

//从图片浏览器拿到当前显示的 cell
- (UICollectionViewCell *)getCurrentCellFromBrowser:(IPImageReaderViewController *)browser
{
    if (!browser) return nil;
    UICollectionViewCell *cell = [browser.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:browser.currentPage inSection:0]];
    return cell;
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
