//
//  IPickerViewController+AnimationTranstion.m
//  IPickerDemo
//
//  Created by wangjianlong on 2018/6/7.
//  Copyright © 2018年 JL. All rights reserved.
//

#import "IPickerViewController+AnimationTranstion.h"

@implementation IPickerViewController (AnimationTranstion)

- (NSUInteger)realIndexFromPhotoReaderCurrentIndex:(NSUInteger)currentIndex
{
    if (self.canTakePhoto || self.canTakeVideo) {
        currentIndex += 1;
        return currentIndex;
    }
    return currentIndex;
}

@end
