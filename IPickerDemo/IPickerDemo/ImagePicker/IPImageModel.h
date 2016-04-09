//
//  IPImageModel.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    IPAssetModelMediaTypePhoto = 0,
    IPAssetModelMediaTypeLivePhoto,
    IPAssetModelMediaTypeVideo,
    IPAssetModelMediaTypeAudio
} IPAssetModelMediaType;

@interface IPImageModel : NSObject


/**当前是否被选中*/
@property (nonatomic, assign)BOOL isSelect;

/**是否存在一样的图像*/
@property (nonatomic, assign)BOOL isSame;

/**比例缩略图高宽比例*/
@property (nonatomic, assign)CGFloat thumbnailScale;

/**唯一标识符*/
@property (nonatomic, copy)NSString *localIdentiy;

/**图像的url*/
@property (nonatomic, strong)NSURL *assetUrl;

/**asset*/
@property (nonatomic, strong)id asset;

/**长度*/
@property (nonatomic, copy)NSString *videoDuration;

/**类型*/
@property (nonatomic, assign)IPAssetModelMediaType mediaType;

@end
