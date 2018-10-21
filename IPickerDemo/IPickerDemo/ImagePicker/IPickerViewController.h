//
//  IPickerViewController.h
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPAssetModel.h"

typedef NS_OPTIONS(NSUInteger, IPickerViewControllerDisplayStyle) {
    IPickerViewControllerDisplayStyleImage = 0,
    IPickerViewControllerDisplayStyleVideo = 1 << 0
};

typedef void(^RequestImageBlock)(UIImage *image,NSError *error);

@class IPickerViewController;


@protocol IPickerViewControllerDelegate <NSObject>

@optional

- (void)ipicker:(IPickerViewController *)ipicker didClickCancelOrCompleteBtn:(UIButton *)sender;

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

@property(nonatomic, readonly) NSArray <IPAssetModel *>*currentSelectAssets;

/**
 *  最大可选择的图片数量
 *  Note:请传入 "> 0" 的数
 */
@property (nonatomic, assign)NSUInteger maxCount;


/**代理*/
@property (nonatomic, weak)id<IPickerViewControllerDelegate> delegate;

/**是否包含拍摄照片功能*/
@property (nonatomic, assign)BOOL canTakePhoto;

/**是否包含拍摄视频功能*/
@property (nonatomic, assign)BOOL canTakeVideo;

/**
 *  创建对象
 *
 *  @param style 样式
 *
 *  @return 实例
 */
+ (instancetype)instanceWithDisplayStyle:(IPickerViewControllerDisplayStyle)style;

@end

@interface IPickerViewController(GetImage)

/**
 *  通过url获取全屏高清图片
 *
 *  @param url   图片资源的唯一标识
 */
+ (void)getImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block;
/**
 *  通过url获取等比缩略图
 *
 *  @param imageUrl 图片url
 *  @param width    图片宽度
 *  @param block    回调
 */
+ (void)getAspectThumbailImageWithImageURL:(NSURL *)imageUrl Width:(CGFloat)width RequestBlock:(RequestImageBlock)block;
/**
 *  通过url获取缩略图
 *
 *  @param imageUrl 图片url
 *  @param block    回调
 */
+ (void)getThumbailImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block;

@end
