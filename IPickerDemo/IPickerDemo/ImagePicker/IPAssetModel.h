//
//  IPAssetModel.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPProtocol.h"

/**类型*/
typedef NS_ENUM(NSUInteger,  IPAssetModelMediaType) {
    IPAssetModelMediaTypePhoto = 0,
    IPAssetModelMediaTypeLivePhoto,
    IPAssetModelMediaTypeVideo,
    IPAssetModelMediaTypeAudio,
    IPAssetModelMediaTypeTakeVideo,
    IPAssetModelMediaTypeTakePhoto
};

@class AVPlayerItem,CLLocation,PHAsset;
typedef void(^functionBlock)(AVPlayerItem *);


typedef void(^CellClickActionBlock)(id);


@interface IPAssetModel : NSObject<IPAssetModel>

/**创建日期*/
@property (nonatomic, strong)NSDate *creatDate;

/**改动日期  ios8以下系统.此属性为空*/
@property (nonatomic, strong)NSDate *modityDate;

/**地理位置*/
@property (nonatomic, strong)CLLocation *location;

/**当前是否被选中*/
@property (nonatomic, assign)BOOL isSelect;

/**是否存在一样的图像*/
@property (nonatomic, assign)BOOL isSame;

/**比例缩略图高宽比例 内部不要使用,赋值*/
@property (nonatomic, assign)CGFloat priexScale;

/**唯一标识符*/
@property (nonatomic, copy)NSString *localIdentiy;

/**图像的url...ios8之后,是唯一标示,已经被包装为URL*/
@property (nonatomic, strong)NSURL *assetUrl;

/**asset*/
@property (nonatomic, strong)id asset;

/**时间标志的时间长度*/
@property (nonatomic, copy)NSString *videoDuration;

/**类型*/
@property (nonatomic, assign)IPAssetModelMediaType assetType;


/**视频时长*/
@property (nonatomic, assign)NSTimeInterval duration;

/**视频缩略图*/
@property (nonatomic, copy)UIImage *VideoThumbail;

/**cell点击block*/
@property (nonatomic, copy)CellClickActionBlock cellClickBlock;

/**layer*/
@property (nonatomic, weak)CALayer *previewLayer;


@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

+ (IPAssetModel *)assetModelWithImage:(UIImage *)image;
+ (IPAssetModel *)assetModelWithURL:(NSURL *)url;
+ (IPAssetModel *)assetModelWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (IPAssetModel *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

@end
