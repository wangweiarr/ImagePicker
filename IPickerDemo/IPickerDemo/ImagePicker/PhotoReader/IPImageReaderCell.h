//
//  IPImageReaderCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPImageReaderViewController;

@interface IPImageReaderCell : UICollectionViewCell

/**伸缩图*/
@property (nonatomic, readonly)UIScrollView *zoomScroll;
@property (nonatomic, weak)IPImageReaderViewController *readerVc;

@property (nonatomic, readonly) NSString *imgSourceUrl;
@property (nonatomic, readonly) id asset;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIImageView *photoImageView;

@property (nonatomic, readonly) UIImageView *dismissAnimateImageView;    //做动画的图片

- (void)displayImageWithFullScreenImage;
- (void)displayImageWithImage:(UIImage *)image;
- (void)displayImageWithImageUrl:(NSString *)imageURL;
- (void)displayImageWithAlbumAsset:(id)asset;

@end
