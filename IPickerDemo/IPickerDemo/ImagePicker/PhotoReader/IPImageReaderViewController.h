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

@class IPAssetModel,IPickerViewController;
@protocol IPImageReaderViewControllerDelegate<NSObject>

- (void)clickSelectBtnForReaderView:(IPAssetModel *)assetModel;

@end

@interface IPImageReaderViewController : UICollectionViewController

/**代理*/
@property (nonatomic, weak)id <IPImageReaderViewControllerDelegate> delegate;

/**当前选择的图片数量*/
@property (nonatomic, assign)NSUInteger currentSelectCount;

/**最大可选择的图片数量*/
@property (nonatomic, assign)NSUInteger maxSelectCount;

/**图库管理*/
@property (nonatomic, weak)IPAssetManager *manger;

/**3DTouch*/
@property (nonatomic, assign)BOOL forceTouch;


@property (nonatomic, strong) UIColor *animationTranstionBgColor;

@property (nonatomic, readonly)NSUInteger currentPage;

@property (nonatomic, readonly)NSArray *dataArr;

+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPAssetModel *> *)data TargetIndex:(NSUInteger)index;

- (void)setUpCurrentSelectPage:(NSUInteger)page;

@end
