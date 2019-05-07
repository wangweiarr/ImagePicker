//
//  IPTakePhotoViewController.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPTakePhotoViewController;

@protocol IPTakePhotoViewControllerDelegate <NSObject>

- (void)didClickCancelBtnInTakePhotoViewController:(IPTakePhotoViewController *)takePhotoViewController;

@end

@interface IPTakePhotoViewController : UIViewController

/**代理*/
@property (nonatomic, weak)id<IPTakePhotoViewControllerDelegate> delegate;

@end
