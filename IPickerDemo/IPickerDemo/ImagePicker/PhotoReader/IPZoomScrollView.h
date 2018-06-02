//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPTapDetectImageView.h"

@class IPAssetModel,IPickerViewController,IPImageReaderViewController;

@interface IPZoomScrollView : UIScrollView

@property (nonatomic, weak)IPImageReaderViewController *readerVc;

@property (nonatomic, strong) IPAssetModel * imageModel;

@property (nonatomic, readonly)IPTapDetectImageView *photoImageView;
@property (nonatomic, readonly) UIImageView *animateImageView;    //做动画的图片

/**是否显示高清 */
//@property (nonatomic, assign)BOOL isDisplayingHighQuality;

- (void)prepareForReuse;

- (void)displayImage;

- (void)displayImageWithFullScreenImage;

@end
