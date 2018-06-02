//
//  IPImageReaderViewController+AniamtionTranstion.m
//  IPickerDemo
//
//  Created by wangjianlong on 2018/6/2.
//  Copyright © 2018年 JL. All rights reserved.
//

#import "IPImageReaderViewController+AniamtionTranstion.h"

@implementation IPImageReaderViewController (AniamtionTranstion)

- (void)photoReadeWillShowWithTimeInterval:(NSTimeInterval)timeInterval
{
    [UIView animateWithDuration:timeInterval animations:^{
        self.view.backgroundColor = [self.animationTranstionBgColor colorWithAlphaComponent:1];
    }];
}

- (void)photoReadeViewChangeBackgroundAlphaWithScale:(CGFloat )scale
{
    self.view.backgroundColor = [self.animationTranstionBgColor colorWithAlphaComponent:scale];
}

- (void)dismissViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoReaderShowReaderView
{
    self.view.backgroundColor = [self.animationTranstionBgColor colorWithAlphaComponent:1];
    if (self.collectionView.isHidden) self.collectionView.hidden = NO;
}

- (void)photoReaderHideReaderView
{
    if (!self.collectionView.isHidden)  self.collectionView.hidden = YES;
}

@end
