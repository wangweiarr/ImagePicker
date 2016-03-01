//
//  IPImageReaderViewController.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissBlock)();

@class IPImageModel;
@interface IPImageReaderViewController : UICollectionViewController


/**退出控制器时,回调*/
@property (nonatomic, copy)  DismissBlock dismissBlock;

+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPImageModel *> *)data TargetIndex:(NSUInteger)index;

@end
