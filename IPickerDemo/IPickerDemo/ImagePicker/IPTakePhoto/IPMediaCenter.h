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

typedef NS_ENUM(NSInteger, IPAuthorizationStatus) {
    IPAuthorizationStatusNotDetermined = 0,
    IPAuthorizationStatusAuthorized,
    IPAuthorizationStatusAudioDenied
};


@class IPMediaCenter;

@protocol IPMediaCenterDelegate <NSObject>

@optional
- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStopPreview:(AVCaptureVideoPreviewLayer *)preViewLayer;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStartPreview:(AVCaptureVideoPreviewLayer *)preViewLayer;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStartSession:(AVCaptureSession *)session;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter DidStopSession:(AVCaptureSession *)session;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter WillStartSession:(AVCaptureSession *)session;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter WasInterruptedSession:(AVCaptureSession *)session;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter InterruptionEndedSession:(AVCaptureSession *)session;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter didChangeCleanAperture:(CGRect)cleanAperture;

// focus / exposure

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionWillStartFocus:(AVCaptureDevice *)device;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidStopFocus:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionWillChangeExposure:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeExposure:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeFlashMode:(AVCaptureDevice *)device;


// authorization / availability

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeAuthorizationStatus:(IPAuthorizationStatus)status;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeFlashAvailability:(BOOL)availability; // flash or torch is available


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

+(IPMediaCenter *)defaultCenter;
+(void)realeaseCenter;
- (void)startPreview;
- (void)stopPreview;
- (void)captureStillImage:(void (^)(UIImage *image))block;

@end
