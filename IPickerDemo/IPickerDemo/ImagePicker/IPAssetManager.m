//
//  IPAssetManager.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAssetManager.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPImageModel.h"
#import <Photos/Photos.h>
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
+ (instancetype)defaultAssetManager{
    
    IPAssetManager *manager = [[IPAssetManager alloc]init];
    
    return manager;
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
        [self getAllAlbumsIOS7];
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
- (void)getImagesForAlbumUrl:(IPAlbumModel *)albumModel{
    if (iOS8Later) {
        [self getImagesForAlbumUrl:albumModel];
//        if (self.allImageModel.count == 0) {
//            [self.allImageModel addObjectsFromArray:self.currentPhotosArr];
//        }
//        [self.currentPhotosArr removeAllObjects];
//        [self.tempArray removeAllObjects];
//        [self getAssetsFromFetchResult:albumModel.groupAsset];
    }else{
        [self getImagesForAlbumUrl:albumModel];
    }
    
}
#pragma mark - ios6_ios7 - 
- (void)getAllAlbumsIOS7{
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
                        
                        imgModel.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        [weakSelf.currentPhotosArr addObject:imgModel];
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    [weakSelf performDelegateWithSuccess:YES];
                    
                }
                
                if (group!=nil) {
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    
                    if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                        model.albumName =@"相机胶卷";
                    }else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recently Added"]){
                        model.albumName =@"最近添加";
                    }
                    else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"My Photo Stream"]){
                        model.albumName =@"我的照片流";
                    }
                    else {
                        model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                    }
                    
                    model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                    
                    [weakSelf.albumArr addObject:model];
                    if ([model.albumName isEqualToString:@"相机胶卷"] ||[model.albumName isEqualToString:@"最近添加"]) {
                        model.isSelected = YES;
                        weakSelf.currentAlbumModel = model;
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                        
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
- (void)getAllAlbumsIOS8{
    
    
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ;
        // For iOS 9, We need to show ScreenShots Album && SelfPortraits Album
        if (iOS9Later) {
            smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumVideos;
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
//            NSLog(@"smartAlbums--%@",collection.localizedTitle);
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"]) continue;
            
            IPAlbumModel * model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
                
                [self getAssetsFromFetchResult:fetchResult];
                model.isSelected = YES;
                self.currentAlbumModel = model;
            }
            [self.albumArr addObject:model];
        }
        
        PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        for (PHAssetCollection *collection in albums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
//            NSLog(@"albums--%@",collection.localizedTitle);
            if (fetchResult.count < 1) continue;
            
            [self.albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
            
        }
    
}

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
- (NSString *)getNewAlbumName:(NSString *)name {
    if (iOS8Later) {
        NSString *newName;
        if ([name containsString:@"Roll"])         newName = @"相机胶卷";
        else if ([name containsString:@"Stream"])  newName = @"我的照片流";
        else if ([name containsString:@"Added"])   newName = @"最近添加";
        else if ([name containsString:@"Selfies"]) newName = @"自拍";
        else if ([name containsString:@"shots"])   newName = @"截屏";
        else if ([name containsString:@"Videos"])  newName = @"视频";
        else newName = name;
        return newName;
    } else {
        return name;
    }
}
/// Get Asset 获得照片数组
- (void)getAssetsFromFetchResult:(PHFetchResult *)result{
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        IPAssetModelMediaType type = IPAssetModelMediaTypePhoto;
        if (asset.mediaType == PHAssetMediaTypeVideo)      type = IPAssetModelMediaTypeVideo;
        else if (asset.mediaType == PHAssetMediaTypeAudio) type = IPAssetModelMediaTypeAudio;
        else if (asset.mediaType == PHAssetMediaTypeImage) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = IPAssetModelMediaTypeLivePhoto;
        }
        
        IPImageModel *imgModel = [[IPImageModel alloc]init];
        
        imgModel.imageAsset = asset;
        imgModel.localIdentiy = asset.localIdentifier;
        NSLog(@"%@",asset.localIdentifier);
        if (self.allImageModel.count > 0) {
            [self.allImageModel enumerateObjectsUsingBlock:^(IPImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.localIdentiy isEqualToString:asset.localIdentifier]) {
                    imgModel.isSame = YES;
                    [self.tempArray addObject:obj];
                }
                
            }];
        }
        if (!imgModel.isSame) {
            [self.tempArray addObject:imgModel];
        }
        
    }];
    [self.currentPhotosArr addObjectsFromArray:self.tempArray];
    [self performDelegateWithSuccess:YES];
}
- (void)getPhotoWithAsset:(IPAlbumModel *)albumModel photoWidth:(CGSize)photoSize{
    PHAsset *phAsset = [albumModel.groupAsset lastObject];
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = photoSize.width * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
//    CGFloat pixelHeight = photoSize.height * multiple;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
//    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            albumModel.posterImage = result;
        }
    }];
}



//- (UIImage *)originImage {
//    
//    __block UIImage *resultImage;
//    if (iOS8Later) {
//        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
//        phImageRequestOptions.synchronous = YES;
//        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
//                                                                              targetSize:PHImageManagerMaximumSize
//                                                                             contentMode:PHImageContentModeDefault
//                                                                                 options:phImageRequestOptions
//                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
//                                                                               resultImage = result;
//                                                                           }];
//    } else {
//        CGImageRef fullResolutionImageRef = [_alAssetRepresentation fullResolutionImage];
//        // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息
//        NSString *adjustment = [[_alAssetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
//        if (adjustment) {
//            // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
//            NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
//            CIImage *tempImage = [CIImage imageWithCGImage:fullResolutionImageRef];
//            
//            NSError *error;
//            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
//                                                         inputImageExtent:tempImage.extent
//                                                                    error:&error];
//            CIContext *context = [CIContext contextWithOptions:nil];
//            if (filterArray && !error) {
//                for (CIFilter *filter in filterArray) {
//                    [filter setValue:tempImage forKey:kCIInputImageKey];
//                    tempImage = [filter outputImage];
//                }
//                fullResolutionImageRef = [context createCGImage:tempImage fromRect:[tempImage extent]];
//            }
//        }
//        // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
//        resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[_alAssetRepresentation scale] orientation:(UIImageOrientation)[_alAssetRepresentation orientation]];
//    }
//    _originImage = resultImage;
//    return resultImage;
//}
//
//- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
//    if (_usePhotoKit) {
//        if (_originImage) {
//            // 如果已经有缓存的图片则直接拿缓存的图片
//            if (completion) {
//                completion(_originImage, nil);
//            }
//            return 0;
//        } else {
//            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//            imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
//            imageRequestOptions.progressHandler = phProgressHandler;
//            return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
//                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _originImage 中
//                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//                if (downloadFinined) {
//                    _originImage = result;
//                }
//                if (completion) {
//                    completion(result, info);
//                }
//            }];
//        }
//    } else {
//        if (completion) {
//            completion([self originImage], nil);
//        }
//        return 0;
//    }
//}
@end
