//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAssetModel,IPickerViewController,IPImageReaderViewController;

@interface IPZoomScrollView : UIScrollView

@property (nonatomic, weak)IPImageReaderViewController *readerVc;

@property (nonatomic, readonly) NSString *imgSourceUrl;
@property (nonatomic, readonly) id asset;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIImageView *photoImageView;

@property (nonatomic, readonly) UIImageView *animateImageView;    //做动画的图片

/**是否显示高清 */
//@property (nonatomic, assign)BOOL isDisplayingHighQuality;

- (void)prepareForReuse;

- (void)displayImage;

- (void)displayImageWithFullScreenImage;
- (void)displayImageWithImage:(UIImage *)image;
- (void)displayImageWithImageUrl:(NSString *)imageURL;
- (void)displayImageWithAlbumAsset:(id)asset;

@end
