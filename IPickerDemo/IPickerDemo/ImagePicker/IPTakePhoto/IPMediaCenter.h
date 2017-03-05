//
//  IPMediaCenter.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/3/4.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, IPMirroringMode) {
    IPMirroringAuto,
    IPMirroringOn,
    IPMirroringOff
};

typedef NS_ENUM(NSInteger, IPTakeMediaType) {
    IPTakeMediaTypePhoto,
    IPTakeMediaTypeVideo
};


@class IPMediaCenter;

@protocol IPMediaCenterDelegate <NSObject>

@optional
- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStopPreview:(AVCaptureVideoPreviewLayer *)preViewLayer;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStartPreview:(AVCaptureVideoPreviewLayer *)preViewLayer;

@end

@interface IPMediaCenter : NSObject

/**
 是否使用手机的音量会话  如果手机音量处于关闭时，软件也会没有声音
 */
@property(nonatomic,assign)BOOL usesApplicationAudioSession;

//视频支持镜像  就是视频内容做个反射
@property (nonatomic) IPMirroringMode mirroringMode;

@property (nonatomic,weak) id delegate;

@property (nonatomic,strong,readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic,assign)IPTakeMediaType takeMediaType;

@property(nonatomic,assign)BOOL autoUpdatePreviewOrientation;
@property(nonatomic,assign) AVCaptureVideoOrientation cameraOrientation;
@property(nonatomic,assign) AVCaptureVideoOrientation previewOrientation;

+(IPMediaCenter *)defaultManager;
- (void)startPreview;
- (void)stopPreview;

@end
