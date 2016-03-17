//
//  IPImageModel.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageModel.h"
#import "IPImageReaderViewController.h"
#import "IPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

/**弹出样式*/
typedef NS_ENUM(NSUInteger,  LoadImage) {
    /**由上到下*/
    LoadImageThumibal,
    /**由左到右*/
    LoadImageFullScreen
};

@interface IPImageModel ()

@end

@implementation IPImageModel
- (void)asynLoadThumibImage{
    if (self.thumbnail) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:self.assetUrl
                               resultBlock:^(ALAsset *asset){
                                   
                                   self.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                                   [self postCompleteNotification:LoadImageThumibal];
                               }
                              failureBlock:^(NSError *error) {
                                  [self postCompleteNotification:LoadImageThumibal];
                                  
                              }];
            } @catch (NSException *e) {
            }
        }
    });
}
- (void)asynLoadFullScreenImage{
    if (self.fullRorationImage) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:self.assetUrl
                               resultBlock:^(ALAsset *asset){
                                   
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.fullRorationImage = [UIImage imageWithCGImage:iref];
                                       [self postCompleteNotification:LoadImageFullScreen];
                                   }
                                   
                               }
                              failureBlock:^(NSError *error) {
                                  self.fullRorationImage = nil;
                                  [self postCompleteNotification:LoadImageFullScreen];
                                  
                              }];
            } @catch (NSException *e) {
                
            }
        }
    });
}
- (void)stopAsyncLoadFullImage{
    if (self.fullRorationImage) {
        self.fullRorationImage = nil;
    }else {
        
    }
}
- (void)postCompleteNotification:(LoadImage)imagStyle {
    if (imagStyle == LoadImageFullScreen) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IPICKER_LOADING_DID_END_NOTIFICATION
                                                            object:self];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION
                                                            object:self];
    }
    
}

@end
