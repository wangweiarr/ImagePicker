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


/**当前是否被选中*/
@property (nonatomic, assign)BOOL isSelect;

/**是否存在一样的图像*/
@property (nonatomic, assign)BOOL isSame;


/**alasset*/
@property (nonatomic, strong)ALAsset *alasset;

/**高清图*/
@property (nonatomic, strong)UIImage *fullRorationImage;

- (void)asynLoadFullScreenImage;

/**
 *  以下两个属性是可以直接访问,并且有值的.上面的属性方法勿用..
 *
 *  如果想获取对应的高清图.请使用方法:+ (void)getImageModelWithURL:(NSURL *)url CreatBlock:(CreatImageModelBlock)block;此处拿到的IPImageModel模型便是有值
 *
 */

/**图像的url*/
@property (nonatomic, strong)NSURL *assetUrl;

/**缩略图*/
@property (nonatomic, strong)UIImage *thumbnail;

@end
