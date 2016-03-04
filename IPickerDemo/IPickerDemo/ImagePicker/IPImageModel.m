//
//  IPImageModel.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageModel.h"
#import "IPImageReaderViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface IPImageModel ()
@end

@implementation IPImageModel
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
                                   
                                   self.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                                   self.alasset = asset;
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.fullRorationImage = [UIImage imageWithCGImage:iref];
                                       [self postCompleteNotification];
                                   }
                                   
                               }
                              failureBlock:^(NSError *error) {
                                  self.fullRorationImage = nil;
                                  [self postCompleteNotification];
                                  
                              }];
            } @catch (NSException *e) {
                
            }
        }
    });
}
- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:IPICKER_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

@end
