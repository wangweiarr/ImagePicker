//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPTapDetectImageView.h"
#import "IPAssetBrowserProtocol.h"

@interface IPZoomScrollView : UIScrollView

@property(nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) id<IPAssetBrowserProtocol> assetModel;

@property (nonatomic, readonly) IPTapDetectImageView *photoImageView;


- (void)displayImageWithImage:(UIImage *)image;

- (void)displayImageWithError;

- (void)displayImageWithFullScreenImage:(UIImage *)image;

@end
