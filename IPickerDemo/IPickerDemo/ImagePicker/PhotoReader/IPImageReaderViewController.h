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

@class IPAssetModel,IPickerViewController,IPImageReaderViewController;

@protocol IPImageReaderViewControllerDelegate<NSObject>

- (void)clickSelectBtnForReaderView:(IPAssetModel *)assetModel;

@end

@protocol IPImageReaderViewControllerDataSource<NSObject>

- (NSUInteger)numberOfAssetsOfImageReader:(IPImageReaderViewController *)imageReader;
- (IPAssetModel *)imageReader:(IPImageReaderViewController *)imageReader assetModelWithIndex:(NSUInteger)page;

@end

@interface IPImageReaderViewController : UICollectionViewController

@property (nonatomic, weak) id <IPImageReaderViewControllerDelegate> delegate;
@property (nonatomic, weak) id <IPImageReaderViewControllerDataSource> dataSource;
@property (nonatomic, strong) NSArray <IPAssetModel *>*assets;

@property (nonatomic, readonly) NSUInteger currentPage;

/**当前选择的图片数量*/
@property (nonatomic, assign)NSUInteger currentSelectCount;

/**最大可选择的图片数量*/
@property (nonatomic, assign)NSUInteger maxSelectCount;

/**图库管理*/
@property (nonatomic, weak)IPAssetManager *manger;

/**3DTouch*/
@property (nonatomic, assign)BOOL forceTouch;


+ (instancetype)imageReaderViewControllerWithDatas:(NSArray<IPAssetModel *> *)assets;
+ (instancetype)imageReaderViewControllerWithDataSource:(id<IPImageReaderViewControllerDataSource>)dataSource;

- (void)setUpDefaultShowPage:(NSUInteger)page;

@end
