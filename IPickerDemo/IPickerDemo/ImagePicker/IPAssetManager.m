//
//  IPAssetManager.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAssetManager.h"

#import<AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPImageModel.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
@interface IPAssetManager ()

/**数据模型暂存数组*/
@property (nonatomic, strong)NSMutableArray *tempArray;

/**全部的数据*/
@property (nonatomic, strong)NSMutableArray *allImageModel;
@end

@implementation IPAssetManager

static IPAssetManager *manager;

+ (instancetype)defaultAssetManager{
    if (manager == nil) {
        manager = [[IPAssetManager alloc]init];
    }
    
    return manager;
}
+ (void)freeAssetManger{
    [manager.allImageModel removeAllObjects];
    [manager.albumArr removeAllObjects];
    [manager.currentPhotosArr removeAllObjects];
    manager = nil;
}
- (void)dealloc{
    NSLog(@"IPAssetManager--dealloc");
}
- (void)clearDataCache{
    self.currentAlbumModel = nil;
    self.currentPhotosArr = nil;
    [self.tempArray removeAllObjects];
    [self.allImageModel removeAllObjects];
}
#pragma mark 获取相册的所有图片
- (void)reloadImagesFromLibrary
{
    if (iOS8Later) {
        [self getAllAlbumsIOS8];
    }else{
        [self getAllAlbumsIOS7];

    }
    
}
- (void)performDelegateWithSuccess:(BOOL)success{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusDenied) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageUserDeny:)]) {
                [self.delegate loadImageUserDeny:self];
            }
        }else {
            if (success == NO) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageOccurError:)]) {
                    [self.delegate loadImageOccurError:self];
                }
            }else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                    [self.delegate loadImageDataFinish:self];
                }
            }
            
            
        }
        
        
    });
}
- (void)getImagesForAlbumModel:(IPAlbumModel *)albumModel{
    if (iOS8Later) {
        if (self.allImageModel.count == 0) {
            [self.allImageModel addObjectsFromArray:self.currentPhotosArr];
        }
        [self.currentPhotosArr removeAllObjects];
        [self.tempArray removeAllObjects];
        [self getAssetsFromFetchResult:albumModel.groupAsset];
    }else{
        [self getImagesWithGroupModel:albumModel];
    }
    
}
#pragma mark - ios6_ios7 - 
- (void)getAllAlbumsIOS7{
    //关闭监听共享照片流产生的频繁通知信息
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                [weakSelf performDelegateWithSuccess:NO];
                
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPImageModel *imgModel = [[IPImageModel alloc]init];
                        imgModel.mediaType = IPAssetModelMediaTypePhoto;
                        
                        imgModel.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        [weakSelf.currentPhotosArr addObject:imgModel];
                        
                    }
                }else {
                    NSLog(@"遍历相册完毕");
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    
                    weakSelf.currentAlbumModel.isSelected = YES;
                    [weakSelf.defaultLibrary groupForURL:weakSelf.currentAlbumModel.groupURL resultBlock:^(ALAssetsGroup *group) {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                        [weakSelf performDelegateWithSuccess:YES];
                    } failureBlock:^(NSError *error) {
                        [weakSelf performDelegateWithSuccess:NO];
                    }];
                    
                }
                
                if (group!=nil) {
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    if (model.imageCount > 0) {
                        if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                            model.albumName =@"相机胶卷";
                        }else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recently Added"]){
                            model.albumName =@"最近添加";
                        }
                        else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"My Photo Stream"]){
                            model.albumName =@"我的照片流";
                        }
                        else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"All Photos"]){
                            model.albumName =@"所有照片";
                        }
                        else {
                            model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                        }
                        NSLog(@"%@",(NSString *)[group valueForProperty:ALAssetsGroupPropertyName]);
                        model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                        [weakSelf.albumArr addObject:model];
                        if (weakSelf.currentAlbumModel == nil || weakSelf.currentAlbumModel.imageCount < model.imageCount) {
                            
                            weakSelf.currentAlbumModel = model;
                        }
                    }
                        
                    
                }
                
            };
            
            [weakSelf.defaultLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                   usingBlock:libraryGroupsEnumeration
                                                 failureBlock:failureblock];
        }
        
    });
}
- (void)getImagesWithGroupModel:(IPAlbumModel *)groupModel{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        IPImageModel *model = [[IPImageModel alloc]init];
                        model.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        [weakSelf.allImageModel enumerateObjectsUsingBlock:^(IPImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.assetUrl isEqual:model.assetUrl]) {
                                //此处逻辑要注意..当之前的那张图片已经存在过了,就加到当前数组中
                                [weakSelf.tempArray addObject:obj];
                                model.isSame = YES;
                            }
                        }];
                        if (model.isSame == NO) {
                            [weakSelf.tempArray addObject:model];
                        }
                        
                    }
                }else {
                    [weakSelf.currentPhotosArr addObjectsFromArray:weakSelf.tempArray];
                    [self performDelegateWithSuccess:YES];
                    [weakSelf.tempArray removeAllObjects];
                }
                
            };
            [self.defaultLibrary groupForURL:groupModel.groupURL resultBlock:^(ALAssetsGroup *group) {
                if (weakSelf.allImageModel.count == 0) {
                    [weakSelf.allImageModel addObjectsFromArray:weakSelf.currentPhotosArr];
                }
                [weakSelf.currentPhotosArr removeAllObjects];
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
                
            } failureBlock:^(NSError *error) {
                [self performDelegateWithSuccess:NO];
            }];
        }
        
    });
}
#pragma mark - lazy -
- (ALAssetsLibrary *)defaultLibrary{
    if (_defaultLibrary == nil) {
        _defaultLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _defaultLibrary;
}
- (NSMutableArray *)albumArr{
    if (_albumArr == nil) {
        _albumArr = [NSMutableArray array];
    }
    return _albumArr;
}
- (NSMutableArray *)currentPhotosArr
{
    if (_currentPhotosArr == nil) {
        _currentPhotosArr = [NSMutableArray array];
    }
    return _currentPhotosArr;
}
- (NSMutableArray *)tempArray{
    if (_tempArray == nil) {
        _tempArray = [NSMutableArray array];
    }
    return _tempArray;
}
- (NSMutableArray *)allImageModel{
    if (_allImageModel == nil) {
        _allImageModel = [NSMutableArray array];
    }
    return _allImageModel;
}
#pragma mark - iOS8 -
/**
 *  遍历图库,获得所有相册数据
 */
- (void)getAllAlbumsIOS8{
    
    
        PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ;
        // For iOS 9, We need to show ScreenShots Album && SelfPortraits Album
        if (iOS9Later) {
            smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumFavorites|PHAssetCollectionSubtypeAlbumMyPhotoStream ;
        }
    
        //获取智能相册
        PHFetchOptions *imageOption = [[PHFetchOptions alloc] init];
        imageOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        imageOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum  subtype:smartAlbumSubtype options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"]) continue;
            
            IPAlbumModel * model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            [self.albumArr addObject:model];
            if (self.currentAlbumModel == nil || self.currentAlbumModel.imageCount < model.imageCount) {
                
                self.currentAlbumModel = model;
            }
        }
    
        //获取普通相册
        PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        for (PHAssetCollection *collection in albums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];

            if (fetchResult.count < 1) continue;
            IPAlbumModel * model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            [self.albumArr addObject:model];
            if (self.currentAlbumModel == nil || self.currentAlbumModel.imageCount < model.imageCount) {
                
                self.currentAlbumModel = model;
            }
            
        }
       [self getAssetsFromFetchResult:self.currentAlbumModel.groupAsset];
       self.currentAlbumModel.isSelected = YES;
    
    
}
/**
 *  生成相册模型数据
 *
 *  @param result 系统模型
 *  @param name   系统相册名称
 *
 *  @return 自定义的相册模型
 */
- (IPAlbumModel *)modelWithResult:(id)result name:(NSString *)name{
    IPAlbumModel *model = [[IPAlbumModel alloc] init];
    model.groupAsset = result;
    model.albumName = [self getNewAlbumName:name];
    [self getPhotoWithAsset:model photoWidth:CGSizeMake(50.0f, 50.0f)];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.imageCount = fetchResult.count;
    }
    return model;
}
/**
 *  将英文相册名称转换为中文名称
 *
 *  @param name 英文名
 *
 *  @return 中文名
 */
- (NSString *)getNewAlbumName:(NSString *)name {
    if (iOS8Later) {
        NSString *newName;
        if ([name containsString:@"Roll"])         newName = @"相机胶卷";
        else if ([name containsString:@"Stream"])  newName = @"我的照片流";
        else if ([name containsString:@"Added"])   newName = @"最近添加";
        else if ([name containsString:@"Selfies"]) newName = @"自拍";
        else if ([name containsString:@"shots"])   newName = @"截屏";
        else if ([name containsString:@"Videos"])  newName = @"视频";
        else if ([name containsString:@"Favorites"])  newName = @"个人收藏";
        else if ([name containsString:@"Panoramas"])  newName = @"全景照片";
        else if ([name containsString:@"All Photos"])  newName = @"全部照片";
        else newName = name;
        return newName;
    } else {
        return name;
    }
}
/**
 *  根据一个 相册集合 对象生成对应的 图片模型
 *
 *  @param result 相册集合
 */
- (void)getAssetsFromFetchResult:(PHFetchResult *)result{
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        IPAssetModelMediaType type = IPAssetModelMediaTypePhoto;
        if (asset.mediaType == PHAssetMediaTypeVideo)      type = IPAssetModelMediaTypeVideo;
        else if (asset.mediaType == PHAssetMediaTypeAudio) type = IPAssetModelMediaTypeAudio;
        else if (asset.mediaType == PHAssetMediaTypeImage) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = IPAssetModelMediaTypeLivePhoto;
        }
        
        IPImageModel *imgModel = [[IPImageModel alloc]init];
        imgModel.mediaType = type;
        imgModel.localIdentiy = asset.localIdentifier;
        
        if (self.allImageModel.count > 0) {
            [self.allImageModel enumerateObjectsUsingBlock:^(IPImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj.localIdentiy isEqualToString:asset.localIdentifier]) {
                    imgModel.isSame = YES;
                    [self.tempArray addObject:obj];
                }
                
            }];
        }
        if (imgModel.isSame == NO) {
            [self.tempArray addObject:imgModel];
        }
        
    }];
    [self.currentPhotosArr addObjectsFromArray:self.tempArray];
    [self performDelegateWithSuccess:YES];
}
/**
 *  获取相册的封面图片
 *
 *  @param albumModel 相册模型
 *  @param photoSize  相框尺寸
 */
- (void)getPhotoWithAsset:(IPAlbumModel *)albumModel photoWidth:(CGSize)photoSize{
    PHAsset *phAsset = [albumModel.groupAsset lastObject];
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
   
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = photoSize.width * multiple;
    CGFloat pixelHeight = photoSize.height * multiple;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            albumModel.posterImage = result;
        }
    }];
}

- (void)getAspectPhotoWithAsset:(IPImageModel *)albumModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    if (iOS8Later) {
        [self ios8_AsyncLoadAspectThumbilImageWithSize:photoSize asset:albumModel completion:completion];
    }else {//ios8之前
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    
                    [self.defaultLibrary assetForURL:albumModel.assetUrl
                                         resultBlock:^(ALAsset *asset){
                                             
                                             UIImage *aspectThumbnail = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(aspectThumbnail,nil);
                                             });
                                         }
                                        failureBlock:^(NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil,nil);
                                            });
                                            
                                        }];
                } @catch (NSException *e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,nil);
                    });
                }
            }
        });
    }
}
- (void)getFullScreenImageWithAsset:(IPImageModel *)albumModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    
    if (iOS8Later) {
        [self ios8_AsyncLoadFullScreenImageWithSize:photoSize asset:albumModel completion:completion];
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    
                    [self.defaultLibrary assetForURL:albumModel.assetUrl
                                         resultBlock:^(ALAsset *asset){
                                             
                                             ALAssetRepresentation *rep = [asset defaultRepresentation];
                                             CGImageRef iref = [rep fullScreenImage];
                                             UIImage *fullScreenImage;
                                             if (iref) {
                                                 fullScreenImage = [UIImage imageWithCGImage:iref];
                                                 
                                             }
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(fullScreenImage,nil);
                                             });
                                         }
                                        failureBlock:^(NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil,nil);
                                            });
                                            
                                        }];
                } @catch (NSException *e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,nil);
                    });
                }
            }
        });
    }
    
    
}
- (void)getThumibImageWithAsset:(IPImageModel *)albumModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    if(iOS8Later){
        [self ios8_asynLoadThumibImageWithSize:photoSize asset:albumModel completion:completion];
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    
                    [self.defaultLibrary assetForURL:albumModel.assetUrl
                                         resultBlock:^(ALAsset *asset){
                                             
                                             UIImage *aspectThumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(aspectThumbnail,nil);
                                             });
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(aspectThumbnail,nil);
                                             });
                                         }
                                        failureBlock:^(NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil,nil);
                                            });
                                            
                                        }];
                } @catch (NSException *e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,nil);
                    });
                }
            }
        });
    }
        
    
}

#pragma mark - ios8later -
/**
 *  正方形缩略图
 *
 *  @param imageSize 图片size
 *  @param imagModel 图片模型
 */
- (void)ios8_asynLoadThumibImageWithSize:(CGSize)imageSize asset:(IPImageModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    __block PHAsset *phAsset = nil;
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[imagModel.localIdentiy] options:nil];
    NSLog(@"标识符为%@总共有%tu的资源图片",imagModel.localIdentiy,[result count]);
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            phAsset = obj;
            *stop = YES;
        }
        
    }];
    
//    PHAsset *phAsset = imagModel.imageAsset;
    
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = imageSize.width * multiple;
    CGFloat pixelHeight = imageSize.height * multiple;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
    }];
}
/**
 *  加载高清图
 */
- (void)ios8_AsyncLoadFullScreenImageWithSize:(CGSize)imageSize asset:(IPImageModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    __block PHAsset *phAsset = nil;
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[imagModel.localIdentiy] options:nil];
    NSLog(@"标识符为%@总共有%tu的资源图片",imagModel.localIdentiy,[result count]);
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            phAsset = obj;
            *stop = YES;
        }
        
    }];
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        NSLog(@"高清图--%@",info);
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
    }];
}
/**
 *  高清预览图
 */
- (void)ios8_AsyncLoadAspectThumbilImageWithSize:(CGSize)imageSize asset:(IPImageModel *)imagModel completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    __block PHAsset *phAsset = nil;
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[imagModel.localIdentiy] options:nil];
    NSLog(@"标识符为%@总共有%tu的资源图片",imagModel.localIdentiy,[result count]);
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            phAsset = obj;
            *stop = YES;
        }
        
    }];
//    PHAsset *phAsset = imagModel.imageAsset;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = imageSize.width * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        NSLog(@"高清缩略图--%@",info);
        // 排除取消，错误，得到低清图三种情况，即已经获取到了低清图
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            completion(result,nil);
            
        }else {
            completion(nil,nil);
        }
    }];
}

@end
