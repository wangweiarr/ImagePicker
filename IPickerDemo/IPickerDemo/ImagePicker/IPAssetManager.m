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
}
#pragma mark 获取相册的所有图片
- (void)reloadImagesFromLibrary
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    NSLog(@"%tu",status);
    
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
                        
                        imgModel.alasset = result;
                        
                        imgModel.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        imgModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                        
                        [weakSelf.currentPhotosArr addObject:imgModel];
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    //                    NSLog(@"遍历完毕");
                   [weakSelf performDelegateWithSuccess:YES];
                    
                }
                
                if (group!=nil) {
                    //                    NSLog(@"gg:%@",g);
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    
                    if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                        model.albumName =@"相机胶卷";
                    }else if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Recently Added"]){
                        model.albumName =@"最近添加";
                    }
                    else {
                        model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                    }
                    
                    model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                    NSLog(@"%@",model.albumName);
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
- (void)performDelegateWithSuccess:(BOOL)success{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusAuthorized) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                [self.delegate loadImageDataFinish:self];
            }
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageUserDeny:)]) {
                [self.delegate loadImageUserDeny:self];
            }
        }
    });
}
- (void)getImagesForAlbumUrl:(NSURL *)albumUrl{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            if (weakSelf.allImageModel.count == 0) {
                [weakSelf.allImageModel addObjectsFromArray:weakSelf.currentPhotosArr];
            }
            [weakSelf.currentPhotosArr removeAllObjects];
            [weakSelf.tempArray removeAllObjects];
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                NSLog(@"%@",result);
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPImageModel *imgModel = [[IPImageModel alloc]init];
                        
                        imgModel.alasset = result;
                        
                        imgModel.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        imgModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                        [weakSelf.allImageModel enumerateObjectsUsingBlock:^(IPImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.assetUrl isEqual:imgModel.assetUrl]) {
                                //此处逻辑要注意..当之前的那张图片已经存在过了,就加到当前数组中
                                [weakSelf.tempArray addObject:obj];
                                imgModel.isSame = YES;
                            }
                        }];
                        if (imgModel.isSame == NO) {
                            [weakSelf.tempArray addObject:imgModel];
                        }
                        
                    }
                }else {
                    [weakSelf.currentPhotosArr addObjectsFromArray:weakSelf.tempArray];
                    [self performDelegateWithSuccess:YES];
                }
                
            };
            [self.defaultLibrary groupForURL:albumUrl resultBlock:^(ALAssetsGroup *group) {
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

@end
