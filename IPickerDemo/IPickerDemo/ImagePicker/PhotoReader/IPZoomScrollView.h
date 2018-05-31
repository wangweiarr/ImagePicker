//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPTapDetectImageView.h"

@class IPAssetModel,IPickerViewController;

@interface IPZoomScrollView : UIScrollView

/**核心*/
@property (nonatomic, weak)IPickerViewController *ipVc;

@property (nonatomic) IPAssetModel * imageModel;

@property (nonatomic, strong,readonly)IPTapDetectImageView *photoImageView;

/**是否显示高清 */
//@property (nonatomic, assign)BOOL isDisplayingHighQuality;

- (void)prepareForReuse;

- (void)displayImage;

- (void)displayImageWithFullScreenImage;

@end
