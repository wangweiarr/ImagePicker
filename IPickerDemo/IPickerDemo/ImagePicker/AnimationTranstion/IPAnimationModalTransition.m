//
//  IPAnimationModalTransition.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/2/19.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPAnimationModalTransition.h"
#import "IPAnimationTranstion.h"

@implementation IPAnimationModalTransition

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[IPAnimationTranstion alloc]init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[IPAnimationInverseTransition alloc]init];
}

@end
