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

@class IPImageModel;
@protocol IPImageReaderViewControllerDelegate<NSObject>

- (void)clickSelectBtnForReaderView:(IPImageModel *)assetModel;

@end
@interface IPImageReaderViewController : UICollectionViewController

/**代理*/
@property (nonatomic, weak)id <IPImageReaderViewControllerDelegate> delegate;

/**退出控制器时,回调*/
@property (nonatomic, copy)  FunctionBlock dismissBlock;

/**当前选择的图片数量*/
@property (nonatomic, assign)NSUInteger currentCount;

/**最大可选择的图片数量*/
@property (nonatomic, assign)NSUInteger maxCount;

/**图库管理*/
@property (nonatomic, weak)IPAssetManager *manger;

+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPImageModel *> *)data TargetIndex:(NSUInteger)index;

@end
