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

/**asset 唯一标识符*/
@property (nonatomic, strong)NSURL *url;

/**alasset*/
@property (nonatomic, strong)ALAsset *alasset;

@end
