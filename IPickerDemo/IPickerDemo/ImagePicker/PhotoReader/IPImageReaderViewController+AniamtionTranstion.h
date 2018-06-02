//
//  IPImageReaderViewController+AniamtionTranstion.h
//  IPickerDemo
//
//  Created by wangjianlong on 2018/6/2.
//  Copyright © 2018年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"

@interface IPImageReaderViewController (AniamtionTranstion)

- (void)photoReadeViewChangeBackgroundAlphaWithScale:(CGFloat )scale;
- (void)dismissViewController;
- (void)photoReadeWillShowWithTimeInterval:(NSTimeInterval)timeInterval;
- (void)photoReaderShowReaderView;
- (void)photoReaderHideReaderView;

@end
