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

@property(nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) IPAssetModel * assetModel;

@property (nonatomic, readonly) IPTapDetectImageView *photoImageView;


- (void)prepareForReuse;

- (void)displayImageWithImage:(UIImage *)image;

- (void)displayImageWithError;

- (void)displayImageWithFullScreenImage;

@end
