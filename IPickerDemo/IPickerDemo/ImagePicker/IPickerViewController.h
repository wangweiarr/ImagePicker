//
//  IPickerViewController.h
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPAssetModel.h"


/**弹出样式*/
typedef NS_ENUM(NSUInteger,  IPickerViewControllerPopStyle) {
    /**由上到下*/
    IPickerViewControllerPopStylePresent,
    /**由左到右*/
    IPickerViewControllerPopStylePush
};
/**展示样式*/
typedef NS_ENUM(NSUInteger,  IPickerViewControllerDisplayStyle) {
    /**展示相册*/
    IPickerViewControllerDisplayStyleImage,
    /**展示视频*/
    IPickerViewControllerDisplayStyleVideo
};
typedef void(^RequestImageBlock)(UIImage *image,NSDictionary *info);

@class IPickerViewController;

@protocol IPickerViewControllerDelegate <NSObject>

/**
 *  选择图片完成后的回调方法
 *
 *  @param datas 图片模型数组
 */
- (void)didClickCompleteBtn:(NSArray *)datas;

/**
 *  拍摄视频完成后,的回调方法
 *
 *  @param videoInfo     视频的相关信息
 *  @option videourl:NSURL  videoduration:NSNumber videothumbail:UIImage
 *
 *
 *  @param progressBlock 导出的进度
 */
- (void)imgPicker:(IPickerViewController *)ipVc didFinishCaptureVideoItem:(AVPlayerItem *)playerItem Videourl:(NSURL *)videoUrl videoDuration:(float)duration thumbailImage:(UIImage *)thumbail;

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

/**
 *  创建对象
 *
 *  @param style 样式
 *
 *  @return 实例
 */
+ (instancetype)instanceWithDisplayStyle:(IPickerViewControllerDisplayStyle)style;

/**
 *  通过url获取图片
 *
 *  @param url   图片资源的唯一标识  
 *  @param block 完成block
 */
+ (void)getImageModelWithURL:(NSURL *)url RequestBlock:(RequestImageBlock)block;

@end
