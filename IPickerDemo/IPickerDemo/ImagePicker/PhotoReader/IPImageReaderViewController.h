//
//  IPImageReaderViewController.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPAssetManager.h"

typedef void(^FunctionBlock)();

typedef NS_ENUM(NSInteger, IPImageSourceType) {
    //网络图片
    IPImageSourceTypeNet = 0,
    //相册
    IPImageSourceTypeAlbum,
    //本地图片
    IPImageSourceTypeLocal
};

@class ALAsset,PHAsset,IPImageReaderViewController;


@protocol IPImageReaderViewControllerDelegate<NSObject>

- (void)imageReader:(IPImageReaderViewController *)reader currentAssetIsSelect:(BOOL)unselect;

@end

@protocol IPImageReaderViewControllerDatasource<NSObject>

- (NSUInteger)numberOfAssetsInImageReader:(IPImageReaderViewController *)imageReader;
- (IPImageSourceType)imageReader:(IPImageReaderViewController *)imageReader soureTypeWithIndex:(NSUInteger)index;

@optional
//ALAsset ios8Later PHAsset
- (id)imageReader:(IPImageReaderViewController *)imageReader albumAssetWithIndex:(NSUInteger)index;

- (NSString *)imageReader:(IPImageReaderViewController *)imageReader simpleQualityAssetUrlWithIndex:(NSUInteger)index;
- (NSString *)imageReader:(IPImageReaderViewController *)imageReader highQualityAssetUrlWithIndex:(NSUInteger)index;

- (UIImage *)imageReader:(IPImageReaderViewController *)imageReader simpleQualityAssetImgWithIndex:(NSUInteger)index;
- (UIImage *)imageReader:(IPImageReaderViewController *)imageReader highQualityAssetImgWithIndex:(NSUInteger)index;


- (BOOL)imageReader:(IPImageReaderViewController *)imageReader currentAssetIsSelected:(NSUInteger)index;

@end

@interface IPImageReaderViewController : UIViewController

@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id <IPImageReaderViewControllerDelegate> delegate;
@property (nonatomic, weak) id <IPImageReaderViewControllerDatasource> dataSource;

/**当前选择的图片数量*/
@property (nonatomic, assign)NSUInteger currentSelectCount;

/**最大可选择的图片数量*/
@property (nonatomic, assign)NSUInteger maxSelectCount;

/**3DTouch*/
@property (nonatomic, assign)BOOL forceTouch;


@property (nonatomic, strong) UIColor *animationTranstionBgColor;

@property (nonatomic, readonly)NSUInteger currentPage;

@property (nonatomic, readonly)NSArray *dataArr;

- (void)setUpCurrentSelectPage:(NSUInteger)page;

@end


