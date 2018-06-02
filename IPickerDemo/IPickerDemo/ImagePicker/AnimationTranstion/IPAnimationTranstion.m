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
#import "IPTakePhotoViewController.h"
#import "IPMediaCenter.h"

@interface IPickerViewController ()
/**collectionview*/
@property (nonatomic, strong)UICollectionView *mainView;
@property(nonatomic,strong)NSIndexPath *indexPath;
- (void)getHighQualityImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

- (UICollectionViewCell *)targetCellForIndexPath:(NSIndexPath *)indexPath;

@end



@implementation IPAnimationTranstion
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.6f;
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
    
    [fromVC getHighQualityImageWithAsset:cell.model photoWidth:size completion:^(UIImage *photo, NSDictionary *info) {
        CGSize photosize = photo.size;
        CGSize realPhotoSize = CGSizeMake(size.width, size.width*photosize.height/photosize.width);
        
        UIView *backGroundView = [[UIView alloc]init];
        backGroundView.backgroundColor = [UIColor blackColor];
        
        UIImageView *snapShotView = [[UIImageView alloc]initWithImage:photo];
        
        backGroundView.frame = [containerView convertRect:cell.imgView.frame fromView:cell.imgView.superview];
//         backGroundView.frame = [containerView convertRect:CGRectMake(-10, -10, toVC.view.bounds.size.width + 20, toVC.view.bounds.size.height + 20) fromView:toVC.view];
//        backGroundView.transform = CGAffineTransformScale(backGroundView.transform, 0.1, 0.1);
        
        cell.imgView.hidden = YES;
        snapShotView.frame = [containerView convertRect:cell.imgView.frame fromView:cell.imgView.superview];
        
//        backGroundView.alpha = 0.0f;
        CGRect photoImageViewFrame;
        CGFloat height = fromVC.view.bounds.size.height;
        
        photoImageViewFrame.size = CGSizeMake(realPhotoSize.width, realPhotoSize.height ) ;
        photoImageViewFrame.origin = CGPointMake(0, (height - realPhotoSize.height)/2);
        
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.collectionView.alpha = 0;
        
        
        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:backGroundView];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        
//        [UIView animateWithDuration:0.1 animations:^{
//            backGroundView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.1f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
                [containerView layoutIfNeeded];
                backGroundView.frame = [containerView convertRect:CGRectMake(-10, -10, toVC.view.bounds.size.width + 20, toVC.view.bounds.size.height + 20) fromView:toVC.view];

                
                CGRect rect = [containerView convertRect:photoImageViewFrame fromView:toVC.view];
                snapShotView.frame = rect;
                
                //            toVC.collectionView.alpha = 1.0;
            } completion:^(BOOL finished) {
                //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
                cell.imgView.hidden = NO;
                backGroundView.backgroundColor = [UIColor clearColor];
                toVC.collectionView.alpha = 1.0;
                [containerView sendSubviewToBack:backGroundView];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    
                } completion:^(BOOL finished) {
                    //告诉系统动画结束
                    [snapShotView removeFromSuperview];
                    [backGroundView removeFromSuperview];
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                }];
            }];
    }];
    
}
@end

@implementation IPAnimationInverseTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //获取动画前后两个VC 和 发生的容器containerView
    __block IPickerViewController *toVC = (IPickerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    __block IPImageReaderViewController *fromVC = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __block UIView *containerView = [transitionContext containerView];
    
    __block IPImageReaderCell *cell = (IPImageReaderCell *)[fromVC.collectionView visibleCells].lastObject;
    NSIndexPath *currentIndexPath = [[fromVC.collectionView indexPathsForVisibleItems] lastObject];
    IPImageCell *from_cell = (IPImageCell *)[toVC targetCellForIndexPath:currentIndexPath];
    
    
    [toVC getThumibImageWithAsset:from_cell.model photoWidth:from_cell.bounds.size completion:^(UIImage *photo, NSDictionary *info) {
        
        UIImageView *snapShotView = [[UIImageView alloc]initWithImage:photo];
        
        snapShotView.contentMode = UIViewContentModeScaleAspectFill;
        
        snapShotView.frame = [containerView convertRect:cell.zoomScroll.photoImageView.frame fromView:cell.zoomScroll.superview];
        cell.hidden = YES;
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        
        
        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromVC.view.alpha = 0.0f;
            CGRect rect = [containerView convertRect:from_cell.frame fromView:toVC.mainView];
            snapShotView.frame = rect;
        } completion:^(BOOL finished) {
            //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
            cell.hidden = NO;
            fromVC.view.alpha = 1.0f;
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

@implementation IPAnimationTakePhotoTransition
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.6f;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //获取两个VC 和 动画发生的容器
     IPickerViewController *fromVC = (IPickerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
     IPImageReaderViewController *toVC   = (IPImageReaderViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
     UIView *containerView = [transitionContext containerView];
    
    //对Cell上的 imageView 截图，同时将这个 imageView 本身隐藏
     IPImageCell *cell =(IPImageCell *)[fromVC.mainView cellForItemAtIndexPath:[[fromVC.mainView indexPathsForSelectedItems] firstObject]];
    
    
    CALayer *layer = [IPMediaCenter defaultCenter].previewLayer;
    if (layer.superlayer) {
        [layer removeFromSuperlayer];
    }
        
        UIView *snapShotView = [[UIView alloc]init];
    [snapShotView.layer addSublayer:layer];
        snapShotView.frame = [containerView convertRect:cell.imgView.frame fromView:cell.imgView.superview];
    
        CGRect photoImageViewFrame;
        

        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0.0f;
    photoImageViewFrame = toVC.view.frame;
        
        
        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        
    
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.1f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
            [containerView layoutIfNeeded];
  toVC.view.alpha = 1.0f;
            CGRect rect = [containerView convertRect:photoImageViewFrame fromView:toVC.view];
            snapShotView.frame = rect;
            
        } completion:^(BOOL finished) {
            //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
            
            
            [snapShotView removeFromSuperview];
            
            [layer removeFromSuperlayer];
            layer.frame = toVC.view.layer.frame;
            [toVC.view.layer insertSublayer:layer atIndex:0];
            
            
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            
        }];
}


@end

