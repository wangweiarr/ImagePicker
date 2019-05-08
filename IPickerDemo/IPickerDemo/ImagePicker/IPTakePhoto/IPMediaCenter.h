//
//  IPMediaCenter.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/3/4.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IPAssetManager.h"

typedef void (^CompressProgress)(float);

typedef NS_ENUM(NSInteger, IPMirroringMode) {
    IPMirroringAuto,
    IPMirroringOn,
    IPMirroringOff
};

typedef NS_ENUM(NSInteger, IPTakeMediaType) {
    IPTakeMediaTypePhoto,
    IPTakeMediaTypeVideo
};

typedef NS_ENUM(NSInteger, IPVisionErrorType)
{
    IPVisionErrorUnknown = -1,
    IPVisionErrorCancelled = 100,
    IPVisionErrorSessionFailed = 101,
    IPVisionErrorBadOutputFile = 102
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


- (void)deviceConfigurationFailedWithError:(NSError *)error;

// focus / exposure

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionWillStartFocus:(AVCaptureDevice *)device;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidStopFocus:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionWillChangeExposure:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeExposure:(AVCaptureDevice *)device;

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeFlashMode:(AVCaptureDevice *)device;


// authorization / availability

- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeAuthorizationStatus:(IPAuthorizationStatus)status;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter visionDidChangeFlashAvailability:(BOOL)availability; // flash or torch is available

// video

- (NSString *)mediaCenter:(IPMediaCenter *)mediaCenter willStartVideoCaptureToFile:(NSString *)fileName;
- (void)visionDidStartVideoCapture:(IPMediaCenter *)mediaCenter;
- (void)visionDidPauseVideoCapture:(IPMediaCenter *)mediaCenter; // stopped but not ended
- (void)visionDidResumeVideoCapture:(IPMediaCenter *)mediaCenter;
- (void)visionDidEndVideoCapture:(IPMediaCenter *)mediaCenter;
- (void)mediaCenter:(IPMediaCenter *)mediaCenter capturedVideo:(NSDictionary *)videoDict error:(NSError *)error;

// video capture progress
- (void)mediaCenter:(IPMediaCenter *)mediaCenter didCaptureDuration:(CMTime)duration;
@end

@interface IPMediaCenter : NSObject

/**
 是否使用手机的音量会话  如果手机音量处于关闭时，软件也会没有声音
 */
@property(nonatomic, assign)BOOL usesApplicationAudioSession;

//视频支持镜像  就是视频内容做个反射
@property (nonatomic, assign)IPMirroringMode mirroringMode;

@property (nonatomic, weak)id delegate;

@property (nonatomic, readonly)AVCaptureVideoPreviewLayer *previewLayer;

/**
 默认是输出照片,(video,image)
 */
@property (nonatomic, assign)IPTakeMediaType takeMediaType;

@property (nonatomic, assign)BOOL autoUpdatePreviewOrientation;
@property (nonatomic, assign)AVCaptureVideoOrientation cameraOrientation;
@property (nonatomic, assign)UIImagePickerControllerCameraDevice cameraDevice;
@property (nonatomic, assign)AVCaptureVideoOrientation previewOrientation;
//VIDEO

//缩略图 地址
@property (nonatomic, strong)NSURL *thumbnail;
/*
 AVAssetExportPresetLowQuality=3
 AVAssetExportPresetMediumQuality=2
 AVAssetExportPresetHighestQuality=1
 */
@property (nonatomic, assign)NSInteger exportPresetQuality;
@property (nonatomic, assign)CGFloat exportVideoWidth;
@property (nonatomic, assign)CGFloat exportVideoHeight;

@property (nonatomic, assign)Float64 capturedVideoSeconds;
@property (nonatomic, assign)CMTime maximumCaptureDuration; // automatically triggers vision:capturedVideo:error: after exceeding threshold, (kCMTimeInvalid records without threshold)

// video
// use pause/resume if a session is in progress, end finalizes that recording session

@property (nonatomic, readonly)BOOL supportsVideoCapture;
@property (nonatomic, readonly)BOOL canCaptureVideo;
@property (nonatomic, readonly, getter=isRecording)BOOL recording;
@property (nonatomic, readonly, getter=isPaused)BOOL paused;

+(IPMediaCenter *)defaultCenter;
+(void)realeaseCenter;

- (void)resetVideoCapture;
- (void)startVideoCapture;
- (void)pauseVideoCapture;
- (void)resumeVideoCapture;
- (BOOL)endVideoCapture;
- (void)cancelVideoCapture;
- (void)backspaceVideoCapture;
- (void) exportVideo:(void (^)(BOOL,NSURL *))completion withProgress:(CompressProgress) progress;

- (void)startPreview;
- (void)stopPreview;
- (void)captureStillImage:(void (^)(UIImage *image))block;

//切换前后摄像头
- (BOOL)swichCameras;

@end
