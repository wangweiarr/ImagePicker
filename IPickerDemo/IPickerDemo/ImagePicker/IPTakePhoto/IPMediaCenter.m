//
//  IPMediaCenter.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/3/4.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPMediaCenter.h"
#import "IPVisionUtilities.h"
#import "IPPrivateDefine.h"


@interface VideoSegment : NSObject

@property(nonatomic,strong) NSURL *url;

@property(nonatomic) CMTime duration;

@end

@implementation VideoSegment


-(id) init:(NSURL *)url withDuration:(CMTime) duration
{
    if(self = [super init])
    {
        _url = url;
        _duration = duration;
    }
    return self;
}
@end

// KVO contexts

static NSString * const IPVisionFocusObserverContext = @"IPVisionFocusObserverContext";
static NSString * const IPVisionExposureObserverContext = @"IPVisionExposureObserverContext";
static NSString * const IPVisionWhiteBalanceObserverContext = @"IPVisionWhiteBalanceObserverContext";
static NSString * const IPVisionFlashModeObserverContext = @"IPVisionFlashModeObserverContext";
static NSString * const IPVisionTorchModeObserverContext = @"IPVisionTorchModeObserverContext";
static NSString * const IPVisionFlashAvailabilityObserverContext = @"IPVisionFlashAvailabilityObserverContext";
static NSString * const IPVisionTorchAvailabilityObserverContext = @"IPVisionTorchAvailabilityObserverContext";

@interface IPMediaCenter()
{
    // flags
    
    struct {
        unsigned int previewRunning:1;
        unsigned int changingModes:1;
        unsigned int recording:1;
        unsigned int paused:1;
        unsigned int interrupted:1;
        unsigned int thumbnailEnabled:1;
        unsigned int defaultVideoThumbnails:1;
    } __block _flags;
}
/**
 *  AVCaptureSession 是AVFoundation捕捉栈的核心类.一个捕捉会话相当于一个虚拟的插线板,用于连接输入和输出的资源.捕捉会话管理从物理设备得到的数据流,比如摄像头和麦克风设备,输出到一个或多个目的地,可以动态配置输入和输出的线路,让开发者能够在会话进行中按需重新配置捕捉环境
 */
@property(nonatomic,strong) AVCaptureSession *captureSession;

/**
 前置摄像头
 */
@property(nonatomic,strong) AVCaptureDevice *captureDeviceFront;
@property(nonatomic,strong)AVCaptureDeviceInput *captureDeviceInputFront;

/**
 后置摄像头
 */
@property(nonatomic,strong) AVCaptureDevice *captureDeviceBack;
@property(nonatomic,strong)AVCaptureDeviceInput *captureDeviceInputBack;

/////////////////////只有当拍视频时，才会设置这三个属性//////////
/**
 麦克风
 */
@property(nonatomic,strong) AVCaptureDevice *captureDeviceAudio;
@property(nonatomic,strong)AVCaptureDeviceInput *captureDeviceInputAudio;

/**
 *  AVFondation 定义了AVCaptureOutput许多扩展类...AVCaptureOutput是抽象基类,用于为从捕捉会话得到的数据寻找输出目的地...扩展类AVCaptureStillImageOutput和AVCaptureMovieFileOutput,使用它们可以很容易地实现捕捉静态照片和视频的功能.还可以在这里找到底层扩展:AVCaptureVideoDataOutput,,,AVCaptureAudioDataOutput..使用这些底层输出类需要对捕捉设备的数据渲染有更好的理解,不过这些类可以提供更强大的功能,比如可以对音视频流,进行实时处理.
 */
@property (nonatomic, strong)AVCaptureStillImageOutput *imgOutput;
@property(nonatomic,strong)AVCaptureMovieFileOutput *captureMovieFileOutput;


/**
 当前的设备（备选：前置，后置，麦克风。。。）
 */
@property(nonatomic,strong)AVCaptureDevice * currentDevice;
/**
 当前的输入对象
 */
@property(nonatomic,strong)AVCaptureDeviceInput *currentInput;
/**
 当前的输出对象
 */
@property(nonatomic,strong)AVCaptureOutput *currentOutput;

//视频帧率
@property(nonatomic,assign)NSInteger videoFrameRate;

//界面预览层
@property(nonatomic,strong,readwrite) AVCaptureVideoPreviewLayer *previewLayer;

// 队列
@property(nonatomic,strong)NSOperationQueue *captureSessionDispatchQueue;
@property(nonatomic,strong)NSOperationQueue *captureVideoDispatchQueue;

//指示输出的质量水平或比特率的常量值
//AVCaptureSessionPresetPhoto
//AVCaptureSessionPresetHigh is the default sessionPreset value.
//Clients may set an AVCaptureSession instance's sessionPreset to AVCaptureSessionPresetHigh to achieve high quality video and audio output.
@property(nonatomic,copy) NSString *captureSessionPreset;

//捕获的路径
@property(nonatomic,copy) NSString *captureDirectory;

@property(nonatomic,assign) CMTime startTimestamp;
@property(nonatomic,assign) CMTime lastTimestamp;
@property(nonatomic,assign) CMTime maximumCaptureDuration;

@property(nonatomic,assign) UIImagePickerControllerCameraDevice cameraDevice;



@property(nonatomic,strong) NSMutableSet* captureThumbnailTimes;
@property(nonatomic,strong) NSMutableSet* captureThumbnailFrames;
@end

@implementation IPMediaCenter
#pragma mark - interface

//单例类的静态实例对象，因对象需要唯一性，故只能是static类型
static IPMediaCenter *defaultManager = nil;

/**单例模式对外的唯一接口，用到的dispatch_once函数在一个应用程序内只会执行一次，且dispatch_once能确保线程安全
 */
+(IPMediaCenter *)defaultManager
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [[IPMediaCenter alloc] init];
        }
    });
    return defaultManager;
}
/**覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [super allocWithZone:zone];
        }
    });
    return defaultManager;
}

//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy
{
    return self;
}

//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy
{
    return self;
}


#pragma mark - life

- (id)init
{
    self = [super init];
    if (self) {
        //VGA 视频输出的质量
        _captureSessionPreset = AVCaptureSessionPreset640x480;
//        self.captureDirectory = nil;
//        _videoSegments = [[NSMutableArray alloc] init];
//        
        _autoUpdatePreviewOrientation = YES;
//        _autoFreezePreviewDuringCapture = YES;
        _usesApplicationAudioSession = NO;
        _cameraOrientation = AVCaptureVideoOrientationPortrait;
        // Average bytes per second based on video dimensions
        // lower the bitRate, higher the compression
//        _videoBitRate = AHVideoBitRate640x480;
        
        // default audio/video configuration
//        _audioBitRate = 64000;
        
        // default flags
//        _flags.thumbnailEnabled = YES;
//        _flags.defaultVideoThumbnails = YES;
        
        // setup queues
        _captureSessionDispatchQueue = [[NSOperationQueue alloc]init];
        _captureSessionDispatchQueue.name = @"IPVisionSession";
        
        _captureVideoDispatchQueue = [[NSOperationQueue alloc]init];
        _captureVideoDispatchQueue.name = @"IPVisionVideo";
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:nil];
        
        _maximumCaptureDuration = kCMTimeInvalid;
        
        [self setMirroringMode:IPMirroringAuto];
        
        _captureThumbnailTimes = [[NSMutableSet alloc] init];
        _captureThumbnailFrames = [[NSMutableSet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.delegate = nil;
    self.captureSessionPreset = nil;
    
    [self _destroyCamera];
    
}
#pragma mark - 预览层

/**
 开启预览层  使用默认的会话
 */
- (void)startPreview
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if (!_captureSession) {
            //没有设置会话时,配置设备 会话
            [self setupCamera];
            [self setupSession];
        }
        //设置视频的滤镜 模式
        [self setMirroringMode:_mirroringMode];
        
        if (_previewLayer && _previewLayer.session != _captureSession) {
            _previewLayer.session = _captureSession;
            [self setOrientationForConnection:_previewLayer.connection];
        }
        
        if (![_captureSession isRunning]) {
            [_captureSession startRunning];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([_delegate respondsToSelector:@selector(mediaCenter:DidStartPreview:)]) {
                    [_delegate mediaCenter:self DidStartPreview:_previewLayer];
                }
            }];
            IPLog(@"capture session running");
        }
        _flags.previewRunning = YES;
    }];
}
- (void)stopPreview
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if (!_flags.previewRunning)
            return;
        
        if ([_captureSession isRunning])
            [_captureSession stopRunning];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:DidStopPreview:)]) {
                [_delegate mediaCenter:self DidStopPreview:_previewLayer];
            }
        }];
        IPLog(@"capture session stopped");
        _flags.previewRunning = NO;
    }];
}
#pragma mark - private setup camera
- (void)setUpCaptureOut
{
    NSError *error;
    if (_takeMediaType == IPTakeMediaTypePhoto) {
        _imgOutput = [[AVCaptureStillImageOutput alloc]init];
        _imgOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
        _currentOutput = _imgOutput;
        if ([_captureSession canAddOutput:_imgOutput]) {
            [_captureSession addOutput:_imgOutput];
        }
    }else{
        _captureDeviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _captureDeviceInputAudio = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceAudio error:&error];
        
        if (error) {
            IPLog(@"error setting up audio input (%@)", error);
        }
         //capture device ouputs
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        _currentOutput = _captureMovieFileOutput;
        
        if ([_captureSession canAddInput:_captureDeviceInputAudio]) {
            [_captureSession addInput:_captureDeviceInputAudio];
        }
        
        // capture device initial settings
        _videoFrameRate = 30;
    }
    if ([_captureSession canAddOutput:_currentOutput]) {
        [_captureSession addOutput:_currentOutput];
    }
    
    if ([_captureSession canAddInput:_captureDeviceInputBack]) {
        [_captureSession addInput:_captureDeviceInputBack];
    }
    
    
    
    
    
}
- (void)_destroyCamera{}

/**
 配置相机  
 @note only call from the session queue
 */
- (void)setupCamera
{
    if (_captureSession)
        return;
    
    // create session
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (_usesApplicationAudioSession) {
        _captureSession.usesApplicationAudioSession = YES;
    }
    
    // capture devices
    _captureDeviceFront = [IPVisionUtilities captureDeviceForPosition:AVCaptureDevicePositionFront];
    _captureDeviceBack = [IPVisionUtilities captureDeviceForPosition:AVCaptureDevicePositionBack];
    
    // capture device inputs
    NSError *error = nil;
    _captureDeviceInputFront = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceFront error:&error];
    if (error) {
        IPLog(@"error setting up front camera input (%@)", error);
        error = nil;
    }
    
    _captureDeviceInputBack = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceBack error:&error];
    if (error) {
        IPLog(@"error setting up back camera input (%@)", error);
        error = nil;
    }
    [self setUpCaptureOut];

    
    // add notification observers
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // session notifications
//    [notificationCenter addObserver:self selector:@selector(_sessionRuntimeErrored:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
//    [notificationCenter addObserver:self selector:@selector(_sessionStarted:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
//    [notificationCenter addObserver:self selector:@selector(_sessionStopped:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
//    [notificationCenter addObserver:self selector:@selector(_sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
//    [notificationCenter addObserver:self selector:@selector(_sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
    
    // capture input notifications
//    [notificationCenter addObserver:self selector:@selector(_inputPortFormatDescriptionDidChange:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
//    
//    // capture device notifications
//    [notificationCenter addObserver:self selector:@selector(_deviceSubjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
//    
//    // current device KVO notifications
//    [self addObserver:self forKeyPath:@"currentDevice.adjustingFocus" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFocusObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.adjustingExposure" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionExposureObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionWhiteBalanceObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.flashMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFlashModeObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.torchMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionTorchModeObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.flashAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFlashAvailabilityObserverContext];
//    [self addObserver:self forKeyPath:@"currentDevice.torchAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionTorchAvailabilityObserverContext];
    
    IPLog(@"camera setup");
}
- (void)setupSession
{
    if (!_captureSession) {
        IPLog(@"error, no session running to setup");
        return;
    }
    
    //能够切换设备
    BOOL shouldSwitchDevice = (_currentDevice == nil) ||
    ((_currentDevice == _captureDeviceFront) && (_cameraDevice != UIImagePickerControllerCameraDeviceFront)) ||
    ((_currentDevice == _captureDeviceBack) && (_cameraDevice != UIImagePickerControllerCameraDeviceRear));
    
    IPLog(@"switchDevice %d", shouldSwitchDevice);
    
    if (!shouldSwitchDevice)
        return;
    
    AVCaptureDeviceInput *newDeviceInput = nil;
    AVCaptureDevice *newCaptureDevice = nil;
    
    [_captureSession beginConfiguration];
    
    // setup session device
    if (shouldSwitchDevice) {
        switch (_cameraDevice) {
            case UIImagePickerControllerCameraDeviceFront:
            {
                if (_captureDeviceInputBack)
                    [_captureSession removeInput:_captureDeviceInputBack];
                
                if (_captureDeviceInputFront && [_captureSession canAddInput:_captureDeviceInputFront]) {
                    [_captureSession addInput:_captureDeviceInputFront];
                    newDeviceInput = _captureDeviceInputFront;
                    newCaptureDevice = _captureDeviceFront;
                }
                break;
            }
            case UIImagePickerControllerCameraDeviceRear:
            {
                if (_captureDeviceInputFront)
                    [_captureSession removeInput:_captureDeviceInputFront];
                
                if (_captureDeviceInputBack && [_captureSession canAddInput:_captureDeviceInputBack]) {
                    [_captureSession addInput:_captureDeviceInputBack];
                    newDeviceInput = _captureDeviceInputBack;
                    newCaptureDevice = _captureDeviceBack;
                }
                break;
            }
            default:
                break;
        }
        
    } // shouldSwitchDevice
    
    //如果新的设备没有赋值，就将当前的设备对其进行赋值
    if (!newCaptureDevice)
        newCaptureDevice = _currentDevice;
    
    // setup video connection
    AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // setup input/output
    
    NSString *sessionPreset = _captureSessionPreset;
    
    if (videoConnection) {
        // setup video orientation
        [self setOrientationForConnection:videoConnection];
        
        // setup video stabilization, if available
        if ([videoConnection isVideoStabilizationSupported]) {
            if ([videoConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)]) {
                [videoConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            } else {
                [videoConnection setEnablesVideoStabilizationWhenAvailable:YES];
            }
        }
        // setup video device configuration
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSError *error = nil;
            if ([newCaptureDevice lockForConfiguration:&error]) {
                
                // smooth autofocus for videos
                if ([newCaptureDevice isSmoothAutoFocusSupported])
                    [newCaptureDevice setSmoothAutoFocusEnabled:YES];
                
                [newCaptureDevice unlockForConfiguration];
                
            } else if (error) {
                IPLog(@"error locking device for video device configuration (%@)", error);
            }
            
        }
        
    }
    
    // apply presets
    if ([_captureSession canSetSessionPreset:sessionPreset])
        [_captureSession setSessionPreset:sessionPreset];
    
    if (newDeviceInput)
        _currentInput = newDeviceInput;
    
    // ensure there is a capture device setup
    if (_currentInput) {
        AVCaptureDevice *device = [_currentInput device];
        if (device) {
            //触发kvo
            [self willChangeValueForKey:@"currentDevice"];
            _currentDevice = device;
            [self didChangeValueForKey:@"currentDevice"];
        }
    }
    
    [_captureSession commitConfiguration];
    
    IPLog(@"capture session setup");
}
- (void)setOrientationForConnection:(AVCaptureConnection *)connection
{
    if (!connection || ![connection isVideoOrientationSupported])
        return;
    if (connection.videoOrientation == _cameraOrientation) {
        return;
    }
    [connection setVideoOrientation:_cameraOrientation];
}

#pragma mark - setter
/**
 设置 视频镜像

 @param mirroringMode 镜像的选项
 */
- (void)setMirroringMode:(IPMirroringMode)mirroringMode
{
    _mirroringMode = mirroringMode;
    
    AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureConnection *previewConnection =[_previewLayer connection];
    
    switch (_mirroringMode) {
        case IPMirroringOff:
        {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:NO];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:NO];
                [previewConnection setVideoMirrored:NO];
            }
            break;
        }
        case IPMirroringOn:
        {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:YES];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:NO];
                [previewConnection setVideoMirrored:YES];
            }
            break;
        }
        case IPMirroringAuto:
        default:
        {
            BOOL mirror = (_cameraDevice == UIImagePickerControllerCameraDeviceFront);
            
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:mirror];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:YES];
            }
            
            break;
        }
    }
}
- (void)setCameraOrientation:(AVCaptureVideoOrientation)cameraOrientation
{
    if (cameraOrientation == _cameraOrientation)
        return;
    _cameraOrientation = cameraOrientation;
    
    if (self.autoUpdatePreviewOrientation) {
        [self setPreviewOrientation:cameraOrientation];
    }
}
- (void)setPreviewOrientation:(AVCaptureVideoOrientation)previewOrientation
{
    if (previewOrientation == _previewOrientation)
        return;
    
    if ([_previewLayer.connection isVideoOrientationSupported]) {
        _previewOrientation = previewOrientation;
        [self setOrientationForConnection:_previewLayer.connection];
    }
}
#pragma mark - App NSNotifications

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    IPLog(@"applicationWillEnterForeground");
    __weak typeof(self)weakSelf = self;
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if (!_flags.previewRunning)
            return;
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [weakSelf startPreview];
        }];
    }];
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    IPLog(@"applicationDidEnterBackground");
    if (_flags.recording)
        [self pauseVideoCapture];
    
    if (_flags.previewRunning) {
        [self stopPreview];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _flags.previewRunning = YES;
        }];
    }
}
- (void)pauseVideoCapture
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        _flags.paused = YES; //标记为暂停状态
        
        //这里不直接调用stopRecording；防止还没有真正开始录就执行该操作，导致的一系列怪异问题，包括一直录不停止问题
        
        //        if(_captureMovieFileOutput.isRecording)
        //        {
        //            [_captureMovieFileOutput stopRecording];
        //        }
        
        IPLog(@"pausing video capture");
    }];
}
@end
