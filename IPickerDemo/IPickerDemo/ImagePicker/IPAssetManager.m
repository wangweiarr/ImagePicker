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

/**图库*/
@property (nonatomic, strong)ALAssetsLibrary *defaultLibrary;

@end

@implementation IPAssetManager
+ (instancetype)defaultAssetManager{
   
    IPAssetManager *manager = [[IPAssetManager alloc]init];
   
    return manager;
}
- (void)dealloc{
    NSLog(@"IPAssetManager--dealloc");
}
#pragma mark 获取相册的所有图片
- (void)reloadImagesFromLibrary
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
                if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                    NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
                }else{
                    NSLog(@"相册访问失败.");
                }
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPImageModel *imgModel = [[IPImageModel alloc]init];
                        
                        imgModel.alasset = result;
                        
                        imgModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                        
                        [weakSelf.currentPhotosArr addObject:imgModel];
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    NSLog(@"遍历完毕");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                            [weakSelf.delegate loadImageDataFinish:weakSelf];
                        }
                    });
                    
                }
                
                if (group!=nil) {
                    NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                    NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    
                    if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                        model.albumName =@"相机胶卷";
                    }else {
                        model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                    }
                    
                    model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                    
                    [weakSelf.albumArr addObject:model];
                    
                    if ([model.albumName isEqualToString:@"相机胶卷"]) {
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

+ (UIImage *)getFullScreenImage:(IPImageModel *)model{
    ALAsset *asset = model.alasset;
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    UIImage *fullRotationImage = [UIImage imageWithCGImage:representation.fullResolutionImage];
    return fullRotationImage;
}

- (void)getImagesForAlbumUrl:(NSURL *)albumUrl{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            [weakSelf.currentPhotosArr removeAllObjects];
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPImageModel *imgModel = [[IPImageModel alloc]init];
                        
                        imgModel.alasset = result;
                        
                        imgModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                        
                        [weakSelf.currentPhotosArr addObject:imgModel];
                       
                        
                    }
                }else {
                    NSLog(@"遍历完毕");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loadImageDataFinish:)]) {
                            [weakSelf.delegate loadImageDataFinish:weakSelf];
                        }
                    });
                }
                
            };
            [self.defaultLibrary groupForURL:albumUrl resultBlock:^(ALAssetsGroup *group) {
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
            } failureBlock:^(NSError *error) {
                
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

- (NSMutableArray *)currentPhotosArr{
    if (_currentPhotosArr == nil) {
        _currentPhotosArr = [NSMutableArray array];
    }
    return _currentPhotosArr;
}
@end
