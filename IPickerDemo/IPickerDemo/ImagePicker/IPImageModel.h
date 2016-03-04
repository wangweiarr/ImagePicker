//
//  IPImageModel.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAsset;

@interface IPImageModel : NSObject

/**缩略图*/
@property (nonatomic, strong)UIImage *thumbnail;

/**当前是否被选中*/
@property (nonatomic, assign)BOOL isSelect;

/**是否存在一样的图像*/
@property (nonatomic, assign)BOOL isSame;

/**图像的url*/
@property (nonatomic, strong)NSURL *assetUrl;

/**alasset*/
@property (nonatomic, strong)ALAsset *alasset;

/**高清图*/
@property (nonatomic, strong)UIImage *fullRorationImage;


- (void)asynLoadFullScreenImage;
@end
