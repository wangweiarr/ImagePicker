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

typedef void(^RequestImageBlock)(UIImage *image,NSError *error);

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

/**图库*/
@property (nonatomic, strong)ALAssetsLibrary *defaultLibrary;

+ (instancetype)defaultAssetManager;
- (void)clearAssetManagerData;

- (void)requestUserpermission;
- (void)reloadImagesFromLibrary;
- (void)reloadVideosFromLibrary;

- (void)getImagesForAlbumModel:(IPAlbumModel *)albumModel;
- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getHighQualityImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getHighQualityImageWithMutipleAsset:(id)asset photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getFullScreenImageWithMutipleAsset:(id)asset photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

- (void)getVideoWithAsset:(IPAssetModel *)imageModel Completion:(void (^)(AVPlayerItem *item,NSDictionary *info))completion;

/**
 *  通过url获取全屏高清图片
 *
 *  @param url   图片资源的唯一标识
 */
+ (void)getImageWithImageURL:(NSString *)imageUrl RequestBlock:(RequestImageBlock)block;
+ (void)getImageWithImageURL:(NSString *)imageUrl width:(CGFloat)width RequestBlock:(RequestImageBlock)block;
/**
 *  通过url获取等比缩略图
 *
 *  @param imageUrl 图片url
 *  @param width    图片宽度
 *  @param block    回调
 */
+ (void)getThumbailImageWithImageURL:(NSString *)imageUrl Width:(CGFloat)width RequestBlock:(RequestImageBlock)block;

+ (void)getThumbailImageWithImageURL:(NSString *)imageUrl RequestBlock:(RequestImageBlock)block;


#pragma mark - video
- (void)compressVideoWithAssetModel:(IPAssetModel *)assetModel CompleteBlock:(functionBlock)block;
- (void)getAspectThumbailWithModel:(IPAssetModel *)model completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
@end
