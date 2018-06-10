//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPTapDetectImageView.h"

@class IPAssetModel;

@interface IPZoomScrollView : UIScrollView

@property (nonatomic) IPAssetModel * imageModel;

@property (nonatomic, strong,readonly)IPTapDetectImageView *photoImageView;


- (void)prepareForReuse;

- (void)displayImage;

- (void)displayImageWithFullScreenImage;

@end
