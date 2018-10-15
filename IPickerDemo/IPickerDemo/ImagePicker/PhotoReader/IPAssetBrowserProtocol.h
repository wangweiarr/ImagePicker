//
//  IPAsset.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2018/10/14.
//  Copyright © 2018 JL. All rights reserved.
//

#ifndef IPAssetProtocol_h
#define IPAssetProtocol_h

@protocol IPAssetBrowserProtocol <NSObject>

@required

@property (nonatomic, strong) UIImage *underlyingImage;

- (void)loadUnderlyingImageAndComplete:(void(^)(BOOL success,UIImage *image))complete;

- (void)performLoadUnderlyingImageAndComplete:(void(^)(BOOL success,UIImage *image))complete;

- (void)unloadUnderlyingImage;

- (void)loadFullScreenImageAndComplete:(void(^)(BOOL success,UIImage *image))complete;

- (void)performLoadFullScreenImageAndComplete:(void(^)(BOOL success,UIImage *image))complete;

- (void)unloadFullScreenImage;



@optional

@property (nonatomic) BOOL isVideo;
- (void)getVideoURL:(void (^)(NSURL *url))completion;
- (void)cancelAnyLoading;

@end

#endif /* IPAsset_h */
