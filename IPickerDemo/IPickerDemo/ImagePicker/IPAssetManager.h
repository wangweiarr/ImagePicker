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

typedef NS_ENUM(NSInteger, IPAuthorizationStatus) {
    IPAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    IPAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    IPAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
    IPAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
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

/**图库*/
@property (nonatomic, strong)ALAssetsLibrary *defaultLibrary;

+ (IPAuthorizationStatus)authorizationStatus;
+ (void)requestAuthorization:(void(^)(IPAuthorizationStatus status))handler;

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

- (void)getVideoWithAsset:(IPAssetModel *)imageModel Completion:(void (^)(AVPlayerItem *item,NSDictionary *info))completion;


- (void)compressVideoWithAssetModel:(IPAssetModel *)assetModel CompleteBlock:(functionBlock)block;
- (void)getAspectThumbailWithModel:(IPAssetModel *)model completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
@end
