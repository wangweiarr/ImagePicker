//
//  IPickerViewController.h
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**弹出样式*/
typedef NS_ENUM(NSUInteger,  IPickerViewControllerPopStyle) {
    /**由上到下*/
    IPickerViewControllerPopStylePresent,
    /**由左到右*/
    IPickerViewControllerPopStylePush
};

@protocol IPickerViewControllerDelegate <NSObject>

- (void)didClickCompleteBtn:(NSArray *)datas;

@end

@interface IPickerViewController : UIViewController

/**
 *  弹出样式
 */
@property (nonatomic, assign)IPickerViewControllerPopStyle popStyle;

/**
 *  最大可选择的图片数量
 *  Note:请传入 "> 0" 的数
 */
@property (nonatomic, assign)NSUInteger maxCount;


/**代理*/
@property (nonatomic, weak)id<IPickerViewControllerDelegate> delegate;

@end
