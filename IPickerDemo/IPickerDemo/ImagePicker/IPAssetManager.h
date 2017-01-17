//
//  IPAssetManager.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IPAssetModel.h"


@class IPAssetManager,IPAlbumModel,ALAssetsLibrary,PHFetchResult;

/**展示样式*/
typedef NS_ENUM(NSUInteger,  IPAssetManagerDataType) {
    /**展示相册*/
    IPAssetManagerDataTypeImage,
    /**展示视频*/
    IPAssetManagerDataTypeVideo
};

@protocol IPAssetManagerDelegate <NSObject>


- (void)loadImageDataFinish:(IPAssetManager *)manager;

- (void)loadImageUserDeny:(IPAssetManager *)manager;
- (void)loadImageOccurError:(IPAssetManager *)manager;
@end




@interface IPAssetManager : NSObject

@property (nonatomic, weak) id <IPAssetManagerDelegate> delegate;

/**相册数组*/
@property (nonatomic, strong,readonly)NSMutableArray *albumArr;

/**当前显示的照片数组*/
@property (nonatomic, strong,readonly)NSMutableArray *currentPhotosArr;

/**当前显示的专辑列表*/
@property (nonatomic, strong)IPAlbumModel *currentAlbumModel;

/**当前存储的数据类型*/
@property (nonatomic, assign)IPAssetManagerDataType dataType;

+ (instancetype)defaultAssetManager;
- (void)clearAssetManagerData;
/**图库*/
@property (nonatomic, strong)ALAssetsLibrary *defaultLibrary;

/**访问类型*/
@property (nonatomic, assign)BOOL isImage;
- (void)requestUserpermission;
- (void)reloadImagesFromLibrary;
- (void)reloadVideosFromLibrary;

- (void)getImagesForAlbumModel:(IPAlbumModel *)albumModel;
- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getHighQualityImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)compressVideoWithAssetModel:(IPAssetModel *)assetModel CompleteBlock:(functionBlock)block;
- (void)getAspectThumbailWithModel:(IPAssetModel *)model completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
@end
