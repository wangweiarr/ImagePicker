//
//  IPAnimationTranstion.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPAnimationTranstion.h"
#import "IPickerViewController.h"
#import "IPImageReaderViewController.h"
#import "IPImageCell.h"
#import "IPAssetManager.h"
#import "IPImageReaderCell.h"
#import "IPZoomScrollView.h"

@interface IPickerViewController ()
/**collectionview*/
@property (nonatomic, strong)UICollectionView *mainView;
@property(nonatomic,assign)CGRect finalCellRect;
@property(nonatomic,strong)NSIndexPath *indexPath;
- (void)getHighQualityImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
@end

@interface IPImageReaderViewController ()
/**collectionview*/
@property (strong, nonatomic) UIImageView *imageViewForSecond;

@end

@implementation IPAnimationTranstion
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3f;
}

//UIViewControllerAnimatedTransitioning
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //获取两个VC 和 动画发生的容器
    __block IPickerViewController *fromVC = (IPickerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __block IPImageReaderViewController *toVC   = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    __block UIView *containerView = [transitionContext containerView];
    
    
    //对Cell上的 imageView 截图，同时将这个 imageView 本身隐藏
    __block IPImageCell *cell =(IPImageCell *)[fromVC.mainView cellForItemAtIndexPath:[[fromVC.mainView indexPathsForSelectedItems] firstObject]];
    fromVC.indexPath = [[fromVC.mainView indexPathsForSelectedItems]firstObject];
    
    __block CGSize size = CGSizeMake(fromVC.view.bounds.size.width, fromVC.view.bounds.size.height);
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        size = CGSizeMake(fromVC.view.bounds.size.height, fromVC.view.bounds.size.width);
    }
    
//    __block CGSize photosize;
//    __block UIImageView *snapShotView;
    [fromVC getHighQualityImageWithAsset:cell.model photoWidth:size completion:^(UIImage *photo, NSDictionary *info) {
        CGSize photosize = photo.size;
        UIImageView *snapShotView = [[UIImageView alloc]initWithImage:photo];
        
        
        snapShotView.frame = fromVC.finalCellRect = [containerView convertRect:cell.imgView.frame fromView:cell.imgView.superview];
        cell.imgView.hidden = YES;
        
        
        CGRect photoImageViewFrame;
        CGFloat height = fromVC.view.bounds.size.height;
        
        photoImageViewFrame.size = CGSizeMake(photosize.width, photosize.height + 20) ;
        photoImageViewFrame.origin = CGPointMake(0, (height - photosize.height)/2 - 10);
        
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        toVC.imageViewForSecond.hidden = YES;
        
        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
//            [containerView layoutIfNeeded];
//            toVC.view.alpha = 1.0;
//            
//            snapShotView.frame = photoImageViewFrame;
//        } completion:^(BOOL finished) {
//            //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
//            cell.imgView.hidden = NO;
//            [snapShotView removeFromSuperview];
//            //告诉系统动画结束
//            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//        }];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.0;
            CGRect rect = [containerView convertRect:photoImageViewFrame fromView:toVC.view];
            snapShotView.frame = rect;
        } completion:^(BOOL finished) {
            //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
            cell.imgView.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                snapShotView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [snapShotView removeFromSuperview];
                //告诉系统动画结束
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
            
        }];
    }];
    
}
@end

@implementation IPAnimationInverseTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.6f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //获取动画前后两个VC 和 发生的容器containerView
    IPickerViewController *toVC = (IPickerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    IPImageReaderViewController *fromVC = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    IPImageReaderCell *cell = (IPImageReaderCell *)[fromVC.collectionView visibleCells].lastObject;
    NSIndexPath *currentIndexPath = [[fromVC.collectionView indexPathsForVisibleItems] lastObject];
    IPImageCell *from_cell = (IPImageCell *)[toVC.mainView cellForItemAtIndexPath:currentIndexPath];
    //在前一个VC上创建一个截图
    UIView  *snapShotView = [cell.zoomScroll.photoImageView snapshotViewAfterScreenUpdates:NO];
    
    snapShotView.backgroundColor = [UIColor clearColor];
    snapShotView.frame = [containerView convertRect:cell.zoomScroll.photoImageView.frame fromView:cell.zoomScroll.superview];
    cell.hidden = YES;
    
    //初始化后一个VC的位置
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    //顺序很重要，
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    [containerView addSubview:snapShotView];
    
    //发生动画
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        fromVC.view.alpha = 0.0f;
//        snapShotView.frame = [containerView convertRect:from_cell.frame fromView:toVC.mainView];
//    } completion:^(BOOL finished) {
//        [snapShotView removeFromSuperview];
//        fromVC.imageViewForSecond.hidden = NO;
//        cell.hidden = NO;
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromVC.view.alpha = 0.0f;
        snapShotView.frame = [containerView convertRect:from_cell.frame fromView:toVC.mainView];
    } completion:^(BOOL finished) {
        //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
        [snapShotView removeFromSuperview];
        fromVC.imageViewForSecond.hidden = NO;
        cell.hidden = NO;
        //告诉系统动画结束
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}
@end
