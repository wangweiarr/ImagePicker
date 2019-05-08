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
#import <AssetsLibrary/AssetsLibrary.h>

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
static NSString * const IPVisionCaptureDurationObserverContext = @"IPVisionCaptureDurationObserverContext";


//拍视频所需的硬盘最小空间
static uint64_t const IPVisionRequiredMinimumDiskSpaceInBytes = 49999872; // ~ 47 MB



@interface IPMediaCenter()<AVCaptureFileOutputRecordingDelegate>
{
    // flags
    
    struct {
        //当前的状态是 正在预览中...
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
@property(nonatomic,strong) AVCaptureDeviceInput *captureDeviceInputFront;

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
//@property(nonatomic,assign) CMTime maximumCaptureDuration;

//@property(nonatomic,assign) UIImagePickerControllerCameraDevice cameraDevice;



@property(nonatomic,strong) NSMutableSet* captureThumbnailTimes;
@property(nonatomic,strong) NSMutableSet* captureThumbnailFrames;

//需要清除孔径的范围
@property(nonatomic,assign)CGRect cleanAperture;

//视频集合
@property(nonatomic,strong) NSMutableArray *videoSegments;

@property(nonatomic,strong) NSTimer *reCoadingtimer;
@property(nonatomic,strong) NSTimer *exporttimer;

@end

@implementation IPMediaCenter
#pragma mark - interface

//单例类的静态实例对象，因对象需要唯一性，故只能是static类型
static IPMediaCenter *defaultManager = nil;

+(void)realeaseCenter{
    if (defaultManager) {
        defaultManager = nil;
    }
    
}

/**单例模式对外的唯一接口，用到的dispatch_once函数在一个应用程序内只会执行一次，且dispatch_once能确保线程安全
 */
+(IPMediaCenter *)defaultCenter
{
//    static dispatch_once_t token;
//    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [[IPMediaCenter alloc] init];
        }
//    });
    return defaultManager;
}
/**覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+(id)allocWithZone:(struct _NSZone *)zone
{
//    static dispatch_once_t token;
//    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [super allocWithZone:zone];
        }
//    });
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
        _captureSessionPreset = AVCaptureSessionPresetPhoto;
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
        _captureSessionDispatchQueue.maxConcurrentOperationCount = 1;
        
        _captureVideoDispatchQueue = [[NSOperationQueue alloc]init];
        _captureVideoDispatchQueue.name = @"IPVisionVideo";
        
        _captureVideoDispatchQueue.maxConcurrentOperationCount = 1;
        
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
    
    [self IP_destroyCamera];
    
    IPLog(@"IPMediaCenter dealloc");
    
}
#pragma mark - preview

/**
 开启预览层  使用默认的会话
 */
- (void)startPreview
{
    IPLog(@"%@ %@",[NSThread currentThread],NSStringFromSelector(_cmd));
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
            
            IPLog(@"%@ %@ [_captureSession startRunning]",NSStringFromSelector(_cmd),[NSThread currentThread]);
            
        }
        _flags.previewRunning = YES;
        IPLog(@"%@ %@ _flags.previewRunning = YES",NSStringFromSelector(_cmd),[NSThread currentThread]);
    }];
}
- (void)stopPreview
{
    
    IPLog(@"%@ %@",[NSThread currentThread],NSStringFromSelector(_cmd));
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        //此时已经停止,就返回
        if (!_flags.previewRunning)
        {
            
            IPLog(@"%@ %@ _flags.previewRunning == NO",NSStringFromSelector(_cmd),[NSThread currentThread]);
            return;
        }
        
        
        if ([_captureSession isRunning])
        {
            
            IPLog(@"%@ %@ [_captureSession stopRunning]",NSStringFromSelector(_cmd),[NSThread currentThread]);
            
            [_captureSession stopRunning];
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:DidStopPreview:)]) {
                [_delegate mediaCenter:self DidStopPreview:_previewLayer];
            }
        }];
        
        IPLog(@"%@ capture session stopped _flags.previewRunning = NO",[NSThread currentThread]);
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
        
        if ([_captureSession canAddInput:_captureDeviceInputAudio]) {
            [_captureSession addInput:_captureDeviceInputAudio];
        }
        if (error) {
            IPLog(@"error setting up audio input (%@)", error);
        }
         //capture device ouputs
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        [_captureMovieFileOutput addObserver:self forKeyPath:@"recordedDuration" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionCaptureDurationObserverContext];
        _currentOutput = _captureMovieFileOutput;
        if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
            [_captureSession addOutput:_captureMovieFileOutput];
        }
        
        // capture device initial settings
        _videoFrameRate = 30;
    }
    
    if ([_captureSession canAddInput:_captureDeviceInputBack]) {
        [_captureSession addInput:_captureDeviceInputBack];
    }
    
    
}
- (void)IP_destroyCamera{
    if (!_captureSession)
        return;
    
    // current device KVO notifications
    @try{
        [self removeObserver:self forKeyPath:@"currentDevice.adjustingFocus"];
        [self removeObserver:self forKeyPath:@"currentDevice.adjustingExposure"];
        [self removeObserver:self forKeyPath:@"currentDevice.adjustingWhiteBalance"];
        [self removeObserver:self forKeyPath:@"currentDevice.flashMode"];
        [self removeObserver:self forKeyPath:@"currentDevice.torchMode"];
        [self removeObserver:self forKeyPath:@"currentDevice.flashAvailable"];
        [self removeObserver:self forKeyPath:@"currentDevice.torchAvailable"];
        
        [_captureMovieFileOutput removeObserver:self forKeyPath:@"recordedDuration"];
    }@catch(NSException *anException){
        IPLog(@"removeObserver-->%@ %@",anException.name,anException.reason);
    }
    @finally {
        IPLog(@"IP_destroyCamera");
    }
    // remove notification observers (we don't want to just 'remove all' because we're also observing background notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // session notifications
    [notificationCenter removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
    
    // capture input notifications
    [notificationCenter removeObserver:self name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
    // capture device notifications
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    
    //    AH_RELEASE_SAFELY(_captureMovieFileOutput);
    
    _captureDeviceAudio = nil;
    
    _captureDeviceInputAudio = nil;
    
    _captureDeviceInputFront = nil;
    
    _captureDeviceInputBack = nil;
    
    _captureDeviceFront = nil;
    
    _captureDeviceBack = nil;
    
    _captureSession = nil;
    
    _currentDevice = nil;
    
    _currentInput = nil;
    
    _currentOutput = nil;
    
    IPLog(@"camera destroyed");
}

- (AVCaptureSession *)captureSession
{
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

/**
 配置相机  
 @note only call from the session queue
 */
- (void)setupCamera
{
    IPLog(@"%@",NSStringFromSelector(_cmd));
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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // session notifications
    [notificationCenter addObserver:self selector:@selector(IP_sessionRuntimeErrored:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(IP_sessionStarted:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(IP_sessionStopped:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(IP_sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(IP_sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
    
    // capture input notifications
    [notificationCenter addObserver:self selector:@selector(IP_inputPortFormatDescriptionDidChange:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
    // capture device notifications
    //This notification is only sent if you first set subjectAreaChangeMonitoringEnabled to YES
    [notificationCenter addObserver:self selector:@selector(IP_deviceSubjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];

    // current device KVO notifications
    [self addObserver:self forKeyPath:@"currentDevice.adjustingFocus" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFocusObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.adjustingExposure" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionExposureObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionWhiteBalanceObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.flashMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFlashModeObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.torchMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionTorchModeObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.flashAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionFlashAvailabilityObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.torchAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)IPVisionTorchAvailabilityObserverContext];
    
    IPLog(@"camera setup");
}
- (void)setupSession
{
    IPLog(@"%@",NSStringFromSelector(_cmd));
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

/**
 设置相机的方向
 */
- (void)setCameraOrientation:(AVCaptureVideoOrientation)cameraOrientation
{
    if (cameraOrientation == _cameraOrientation)
        return;
    _cameraOrientation = cameraOrientation;
    
    if (self.autoUpdatePreviewOrientation) {
        [self setPreviewOrientation:cameraOrientation];
    }
}

/**
 设置预览图层的方向
 */
- (void)setPreviewOrientation:(AVCaptureVideoOrientation)previewOrientation
{
    if (previewOrientation == _previewOrientation)
        return;
    
    if ([_previewLayer.connection isVideoOrientationSupported]) {
        _previewOrientation = previewOrientation;
        [self setOrientationForConnection:_previewLayer.connection];
    }
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)IPVisionFocusObserverContext ) {
        
        BOOL isFocusing = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isFocusing) {
            [self IP_focusStarted];
        } else {
            [self IP_focusEnded];
        }
        
    }
    else if ( context == (__bridge void *)IPVisionExposureObserverContext ) {
        
        BOOL isChangingExposure = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isChangingExposure) {
            [self IP_exposureChangeStarted];
        } else {
            [self IP_exposureChangeEnded];
        }
        
    }
    else if ( context == (__bridge void *)IPVisionWhiteBalanceObserverContext ) {
        
        BOOL isWhiteBalanceChanging = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isWhiteBalanceChanging) {
            [self IP_whiteBalanceChangeStarted];
        } else {
            [self IP_whiteBalanceChangeEnded];
        }
        
    }
    else if ( context == (__bridge void *)IPVisionFlashAvailabilityObserverContext ||
             context == (__bridge void *)IPVisionTorchAvailabilityObserverContext ) {
        BOOL FlashAvailability = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        //        IPLog(@"flash/torch availability did change");
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter: visionDidChangeFlashAvailability:)])
                [_delegate mediaCenter:self visionDidChangeFlashAvailability:FlashAvailability];
        }];
        
    }
    else if ( context == (__bridge void *)IPVisionFlashModeObserverContext ||
             context == (__bridge void *)IPVisionTorchModeObserverContext ) {
        
        //        IPLog(@"flash/torch mode did change");
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:visionDidChangeFlashMode:)])
                [_delegate mediaCenter:self visionDidChangeFlashMode:_currentDevice];
        }];
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - App NSNotifications

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    IPLog(@"%@",NSStringFromSelector(_cmd));
    __weak typeof(self)weakSelf = self;
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if (!_flags.previewRunning)
        {
            IPLog(@"%@ _flags.previewRunning == NO  RETURN",NSStringFromSelector(_cmd));
            return;
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf startPreview];
        }];
    }];
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    IPLog(@"%@",NSStringFromSelector(_cmd));
    if (_flags.recording)
        [self pauseVideoCapture];
    
    if (_flags.previewRunning) {
        [self stopPreview];
        [_captureSessionDispatchQueue addOperationWithBlock:^{
            
            IPLog(@"%@ %@ _flags.previewRunning = YES",NSStringFromSelector(_cmd),[NSThread currentThread]);
            
            _flags.previewRunning = YES;
        }];
    }
}
#pragma mark - AV NSNotifications

// capture session handlers

- (void)IP_sessionRuntimeErrored:(NSNotification *)notification
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if ([notification object] == _captureSession) {
            NSError *error = [[notification userInfo] objectForKey:AVCaptureSessionErrorKey];
            if (error) {
                switch ([error code]) {
                        //媒体服务重新启动时通知主线程
                    case AVErrorMediaServicesWereReset:
                    {
                        IPLog(@"error media services were reset");
                        [self IP_destroyCamera];
                        if (_flags.previewRunning)
                            [self startPreview];
                        break;
                    }
                    case AVErrorDeviceIsNotAvailableInBackground:
                    {
                        IPLog(@"error media services not available in background");
                        break;
                    }
                    default:
                    {
                        IPLog(@"error media services failed, error (%@)", error);
                        [self IP_destroyCamera];
                        if (_flags.previewRunning)
                            [self startPreview];
                        break;
                    }
                }
            }
        }
    }];
}

- (void)IP_sessionStarted:(NSNotification *)notification
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        if ([notification object] != _captureSession)
            return;
        
        IPLog(@"%@ %@ session was started",NSStringFromSelector(_cmd),[NSThread currentThread]);
        // ensure there is a capture device setup
        if (_currentInput) {
            AVCaptureDevice *device = [_currentInput device];
            if (device) {
                [self willChangeValueForKey:@"currentDevice"];
                _currentDevice = device;
                [self didChangeValueForKey:@"currentDevice"];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(mediaCenter:DidStartSession:)]) {
            [_delegate mediaCenter:self DidStartSession:_captureSession];
        }
    }];
}

- (void)IP_sessionStopped:(NSNotification *)notification
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if ([notification object] != _captureSession)
            return;
        
        IPLog(@"%@ %@ session was stopped",NSStringFromSelector(_cmd),[NSThread currentThread]);
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:DidStopSession:)]) {
                [_delegate mediaCenter:self DidStopSession:_captureSession];
            }
        }];
    }];
}

- (void)IP_sessionWasInterrupted:(NSNotification *)notification
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        if ([notification object] != _captureSession)
            return;
        
        IPLog(@"%@ %@ session was interrupted",NSStringFromSelector(_cmd),[NSThread currentThread]);
        if (_flags.recording) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                if ([_delegate respondsToSelector:@selector(mediaCenter:DidStopSession:)]) {
                    [_delegate mediaCenter:self DidStopSession:_captureSession];
                }
            }];
        }
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:WasInterruptedSession:)]) {
                [_delegate mediaCenter:self WasInterruptedSession:_captureSession];
            }
        }];
    }];
}

- (void)IP_sessionInterruptionEnded:(NSNotification *)notification
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        
        if ([notification object] != _captureSession)
            return;
        
        IPLog(@"session interruption ended");
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(mediaCenter:InterruptionEndedSession:)]) {
                [_delegate mediaCenter:self InterruptionEndedSession:_captureSession];
            }
        }];
    }];
}
// capture input handler

- (void)IP_inputPortFormatDescriptionDidChange:(NSNotification *)notification
{
    // when the input format changes, store the clean aperture
    // (clean aperture is the rect that represents the valid image data for this display)
    AVCaptureInputPort *inputPort = (AVCaptureInputPort *)[notification object];
    if (inputPort) {
        CMFormatDescriptionRef formatDescription = [inputPort formatDescription];
        if (formatDescription) {
            _cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription, YES);
            if ([_delegate respondsToSelector:@selector(mediaCenter:didChangeCleanAperture:)]) {
                [_delegate mediaCenter:self didChangeCleanAperture:_cleanAperture];
            }
        }
    }
}

// capture device handler

- (void)IP_deviceSubjectAreaDidChange:(NSNotification *)notification
{
    [self IP_adjustFocusExposureAndWhiteBalance];
}

- (void)IP_adjustFocusExposureAndWhiteBalance
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    // only notify clients when focus is triggered from an event
    if ([_delegate respondsToSelector:@selector(mediaCenter:visionWillStartFocus:)])
        [_delegate mediaCenter:self visionWillStartFocus:_currentDevice];
    
    CGPoint focusPoint = CGPointMake(0.5f, 0.5f);
    [self IP_FocusAtAdjustedPointOfInterest:focusPoint];
}
/**
 *  对焦到指定点
 */
- (void)IP_FocusAtAdjustedPointOfInterest:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        //锁定设备准备配置.如果获得了锁,将focusPointOfInterest 属性设置为传进来的CGPoint值,设置对焦模式为AVCaptureFocusModeAutoFocus.最后调用unlockForConfiguration 释放该锁定
        BOOL isFocusAtPointSupported = [_currentDevice isFocusPointOfInterestSupported];
        
        if (isFocusAtPointSupported && [_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            AVCaptureFocusMode fm = [_currentDevice focusMode];
            [_currentDevice setFocusPointOfInterest:adjustedPoint];
            [_currentDevice setFocusMode:fm];
        }
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        IPLog(@"error locking device for focus adjustment (%@)", error);
    }
}
#pragma mark - focus, exposure, white balance
- (void)IP_focusStarted
{
    IPLog(@"focus will started");
    if ([_delegate respondsToSelector:@selector(mediaCenter:visionWillStartFocus:)])
    {
        [_delegate mediaCenter:self visionWillStartFocus:_currentDevice];
    }
    
}
- (void)IP_focusEnded
{
    AVCaptureFocusMode focusMode = [_currentDevice focusMode];
    BOOL isFocusing = [_currentDevice isAdjustingFocus];
    BOOL isAutoFocusEnabled = (focusMode == AVCaptureFocusModeAutoFocus ||
                               focusMode == AVCaptureFocusModeContinuousAutoFocus);
    if (!isFocusing && isAutoFocusEnabled) {
        NSError *error = nil;
        if ([_currentDevice lockForConfiguration:&error]) {
            
            [_currentDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [_currentDevice unlockForConfiguration];
            
        } else if (error) {
            IPLog(@"error locking device post exposure for subject area change monitoring (%@)", error);
        }
    }
    
    if ([_delegate respondsToSelector:@selector(mediaCenter:visionDidStopFocus:)])
    {
        [_delegate mediaCenter:self visionDidStopFocus:_currentDevice];
    }
    
    IPLog(@"focus ended");
}

- (void)IP_exposureChangeStarted
{
    //    IPLog(@"exposure change started");
    if ([_delegate respondsToSelector:@selector(mediaCenter:visionWillChangeExposure:)])
        [_delegate mediaCenter:self visionWillChangeExposure:_currentDevice];
}

- (void)IP_exposureChangeEnded
{
    BOOL isContinuousAutoExposureEnabled = [_currentDevice exposureMode] == AVCaptureExposureModeContinuousAutoExposure;
    BOOL isExposing = [_currentDevice isAdjustingExposure];
    BOOL isFocusSupported = [_currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
    
    if (isContinuousAutoExposureEnabled && !isExposing && !isFocusSupported) {
        
        NSError *error = nil;
        if ([_currentDevice lockForConfiguration:&error]) {
            
            [_currentDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [_currentDevice unlockForConfiguration];
            
        } else if (error) {
            IPLog(@"error locking device post exposure for subject area change monitoring (%@)", error);
        }
        
    }
    
    if ([_delegate respondsToSelector:@selector(mediaCenter:visionDidChangeExposure:)])
    {
        [_delegate mediaCenter:self visionDidChangeExposure:_currentDevice];
    }
    IPLog(@"exposure change ended");
}

- (void)IP_whiteBalanceChangeStarted
{
}

- (void)IP_whiteBalanceChangeEnded
{
}


- (void)exposeAtAdjustedPointOfInterest:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        
        BOOL isExposureAtPointSupported = [_currentDevice isExposurePointOfInterestSupported];
        if (isExposureAtPointSupported && [_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            AVCaptureExposureMode em = [_currentDevice exposureMode];
            [_currentDevice setExposurePointOfInterest:adjustedPoint];
            [_currentDevice setExposureMode:em];
        }
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        IPLog(@"error locking device for exposure adjustment (%@)", error);
    }
}


// focusExposeAndAdjustWhiteBalanceAtAdjustedPoint: will put focus and exposure into auto
- (void)focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        
        BOOL isFocusAtPointSupported = [_currentDevice isFocusPointOfInterestSupported];
        BOOL isExposureAtPointSupported = [_currentDevice isExposurePointOfInterestSupported];
        BOOL isWhiteBalanceModeSupported = [_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        if (isFocusAtPointSupported && [_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_currentDevice setFocusPointOfInterest:adjustedPoint];
            [_currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if (isExposureAtPointSupported && [_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_currentDevice setExposurePointOfInterest:adjustedPoint];
            [_currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if (isWhiteBalanceModeSupported) {
            [_currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [_currentDevice setSubjectAreaChangeMonitoringEnabled:NO];
        
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        IPLog(@"error locking device for focus / exposure / white-balance adjustment (%@)", error);
    }
}
#pragma mark - capture image
- (void)captureStillImage:(void (^)(UIImage *image))block{
    AVCaptureConnection *connection = [self.imgOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = _cameraOrientation;
    }
    
    id handler = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer != NULL) {
            NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            if (block) {
                block(image);
            }
//            [self writImageToSavePhotosAlbum:image];
        }else {
            NSLog(@"NULL sampleBuffer:%@",[error localizedDescription]);
        }
    };
    [self.imgOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
}
- (void)postThumbnailNotification:(UIImage *)image{
    
}
- (void)writImageToSavePhotosAlbum:(UIImage *)image{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self postThumbnailNotification:image];
        }
    }];
}
#pragma mark - capture Video
#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void) timeOutputInterval
{
    CMTime duration = CMTimeAdd(_lastTimestamp, _captureMovieFileOutput.recordedDuration);
    
    
    if (_flags.paused || CMTimeCompare(_maximumCaptureDuration, duration)!=1) {
        [_captureVideoDispatchQueue addOperationWithBlock:^{
            [_captureMovieFileOutput stopRecording];
        }];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([_delegate respondsToSelector:@selector(mediaCenter:didCaptureDuration:)])
            [_delegate mediaCenter:self didCaptureDuration:duration];
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    VideoSegment *seg = [[VideoSegment alloc] init: fileURL withDuration:kCMTimeZero];
    [_videoSegments addObject:seg];
    
    
    
    _flags.interrupted = NO;
    
    _reCoadingtimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timeOutputInterval) userInfo:nil repeats:YES];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([_delegate respondsToSelector:@selector(visionDidStartVideoCapture:)])
            [_delegate visionDidStartVideoCapture:self];
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    _flags.interrupted = YES;
    
    
    if (_reCoadingtimer==nil){ return; };
    [_reCoadingtimer invalidate];
    _reCoadingtimer = nil;
    
    if (error) {
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"写入失败,请重新拍摄" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        [alertView show];
        //        [alertView release];
        //
        //        [self _enqueueBlockOnMainQueue:^{
        //            if ([_delegate respondsToSelector:@selector(vision:didCaptureDuration:)])
        //                [_delegate vision:self didCaptureDuration:_lastTimestamp];
        //        }];
        
        return;
    };
    
    AVCaptureMovieFileOutput *output =(AVCaptureMovieFileOutput *)captureOutput;
    
    _lastTimestamp = CMTimeAdd(_lastTimestamp, output.recordedDuration);
    
    VideoSegment *seg = [_videoSegments lastObject];
    seg.duration = output.recordedDuration;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([_delegate respondsToSelector:@selector(visionDidPauseVideoCapture:)])
            [_delegate visionDidPauseVideoCapture:self];
    }];
}
#pragma mark - video
- (NSString *) getTemporayPath:(NSString *)extension
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if(!self.captureDirectory)
    {
        formatter.dateFormat = @"yyyyMMddHHmm";
        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dir = [[dir stringByAppendingPathComponent:@"videos"]
               stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
        
        if (![IPVisionUtilities createFolderIfNotExist:dir]) {
            [self _failVideoCaptureWithErrorCode:IPVisionErrorBadOutputFile];
        }
        self.captureDirectory = dir;
    }
    formatter.dateFormat = @"yyyyMMddHHmmsss";
    NSString *outputPath = [self.captureDirectory stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
    
    return [outputPath stringByAppendingString:extension];
}


- (void)resetVideoCapture
{
    self.captureDirectory = nil;
    
    _flags.recording = NO;
    _flags.paused = NO;
    _flags.interrupted = YES;
    
    _startTimestamp =kCMTimeZero;
    _lastTimestamp = kCMTimeZero;
    
    self.thumbnail = nil;
    [_videoSegments removeAllObjects];
    
    [_captureThumbnailTimes removeAllObjects];
    [_captureThumbnailFrames removeAllObjects];
}
- (BOOL)_canSessionCaptureWithOutput:(AVCaptureOutput *)captureOutput
{
    BOOL sessionContainsOutput = [[_captureSession outputs] containsObject:captureOutput];
    BOOL outputHasConnection = ([captureOutput connectionWithMediaType:AVMediaTypeVideo] != nil);
    return (sessionContainsOutput && outputHasConnection);
}

- (void)startVideoCapture
{
    if (![self _canSessionCaptureWithOutput:_currentOutput]) {
        [self _failVideoCaptureWithErrorCode:IPVisionErrorSessionFailed];
        IPLog(@"session is not setup properly for capture");
        return;
    }
    
    IPLog(@"starting video capture");
    
    [_captureVideoDispatchQueue addOperationWithBlock:^{
        
        if (_flags.recording || _flags.paused)
            return;
        _flags.recording = YES;
        _flags.paused = NO;
        
        AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
        [self setOrientationForConnection:videoConnection];
        
        if (!videoConnection.active || !videoConnection.enabled) {
            //解决拍照后  _captureSession 的Preset值被修改导致的崩溃异常
            [_captureSession beginConfiguration];
            if ([_captureSession canSetSessionPreset:_captureSessionPreset])
                [_captureSession setSessionPreset:_captureSessionPreset];
            [_captureSession commitConfiguration];
            
        }
        
        if (_flags.thumbnailEnabled && _flags.defaultVideoThumbnails) {
            [self captureVideoThumbnailAtFrame:0];
        }
        
        // start capture
        NSURL *url = [NSURL fileURLWithPath: [self getTemporayPath:@".mov"]];
        
        
        [_captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    }];
}

/**
 暂停视频捕获
 */
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

- (void)resumeVideoCapture
{
    [_captureSessionDispatchQueue addOperationWithBlock:^{
        if (!_flags.recording || !_flags.interrupted)
            return;
        
        
        if (CMTimeCompare(_maximumCaptureDuration, _lastTimestamp)!=1) {
            return;
        }
        _flags.paused = NO;
        
        // start capture
        NSURL *url = [NSURL fileURLWithPath: [self getTemporayPath:@".mov"]];
        
        [_captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([_delegate respondsToSelector:@selector(visionDidResumeVideoCapture:)])
                [_delegate visionDidResumeVideoCapture:self];
        }];
    }];
}

- (BOOL)endVideoCapture
{
    IPLog(@"ending video capture");
    
    //    [self _enqueueBlockOnCaptureVideoQueue:^{
    if (!_flags.recording) return NO;
    if (!_flags.interrupted) {
        return NO;
    }
    
    _flags.recording = NO;
    _flags.paused = NO;
    //[_captureMovieFileOutput stopRecording];
    //    }];
    
    self.thumbnail = [self _generateThumbnailURL];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([_delegate respondsToSelector:@selector(visionDidEndVideoCapture:)])
            [_delegate visionDidEndVideoCapture:self];
    }];
    return YES;
}

- (void)cancelVideoCapture
{
    IPLog(@"cancel video capture");
    
    [_captureVideoDispatchQueue addOperationWithBlock:^{
        if(_captureMovieFileOutput.isRecording){
            [_captureMovieFileOutput stopRecording];
        }
        //删除临时文件
        [self deleteFiles:self.captureDirectory withExtention:@"mov"];
        
        self.captureDirectory = nil;
        _flags.recording = NO;
        _flags.paused = NO;
        _startTimestamp =kCMTimeZero;
        _lastTimestamp = kCMTimeZero;
        
        self.thumbnail = nil;
        [_videoSegments removeAllObjects];
        
        [_captureThumbnailTimes removeAllObjects];
        [_captureThumbnailFrames removeAllObjects];
    }];
}

- (void)backspaceVideoCapture
{
    VideoSegment *seg = [_videoSegments lastObject];
    [[NSFileManager defaultManager] removeItemAtPath:[seg.url path] error:nil];
    _lastTimestamp = CMTimeSubtract(_lastTimestamp, seg.duration);
    if (!CMTIME_IS_VALID(_lastTimestamp)) {
        _lastTimestamp = kCMTimeZero;
    }
    [_videoSegments removeLastObject];
}

- (NSURL *)_generateThumbnailURL
{
    if(_videoSegments.count==0) return nil;
    
    CGFloat aspecRatio= _previewLayer.bounds.size.height/_previewLayer.bounds.size.width;
    
    VideoSegment *first = [_videoSegments firstObject];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:first.url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generate.appliesPreferredTrackTransform = YES;
    CGImageRef imgRef = [generate copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height =CGImageGetHeight(imgRef);
    CGRect rect = CGRectMake(0, (height- width * aspecRatio)/2, width, width * aspecRatio);
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imgRef, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    CGImageRelease(imgRef);
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* image = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    
    NSString *jpgPath = [self getTemporayPath:@".jpg"];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    return [NSURL fileURLWithPath: jpgPath];
}

- (void) exportVideo:(void (^)(BOOL,NSURL *))completion withProgress:(CompressProgress) progress
{
    /*涉及自动释放的对象比较多，单独使用自动释放池来回收资源*/
    @autoreleasepool {
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *audioTrackInput = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrackInput = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        //fix orientationissue
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        //视频高宽比
        CGFloat videoHWRatio= self.exportVideoHeight / self.exportVideoWidth;
        CMTime totalDuration = kCMTimeZero;
        int i=0;
        for (VideoSegment *seg in _videoSegments) {
            if (seg.duration.value<=0) continue;
            @autoreleasepool {
                AVAsset *asset = [AVAsset assetWithURL:seg.url];
                
                AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                
                [audioTrackInput insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeInvalid error:nil];
                
                [videoTrackInput insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeInvalid error:nil];
                
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
                
                /*
                 因为只允许竖拍，即使用户横拍，也不需要对视频做转向处理，可以只使用一个AVMutableVideoCompositionLayerInstruction
                 来处理。尽量减少内存消耗，否则ios5系统的低端设备视频导出会失败。
                 */
                if (i++==0) {
                    CGFloat rate = self.exportVideoWidth / videoTrack.naturalSize.height;//因为是纵向拍摄，视频现在的height即为实际的宽
                    
                    
                    CGAffineTransform layerTransform = CGAffineTransformMake(videoTrack.preferredTransform.a, videoTrack.preferredTransform.b, videoTrack.preferredTransform.c, videoTrack.preferredTransform.d, videoTrack.preferredTransform.tx * rate, videoTrack.preferredTransform.ty * rate);
                    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (videoTrack.naturalSize.height * videoHWRatio - videoTrack.naturalSize.width)/ 2.0)); //向上移动取中部影响
                    layerTransform = CGAffineTransformScale(layerTransform, rate, rate); //放缩，解决实际影像和最终导出尺寸不一致问题
                    
                    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackInput];
                    [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
                    [layerInstructionArray addObject:layerInstruciton];
                }
            }
        }
        NSString *videoDir = [self.captureDirectory copy]; //保存当前视频目录
        NSURL *output = [NSURL fileURLWithPath:[self getTemporayPath:@"_compress.mp4"]];
        
        
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        
        AVMutableVideoComposition *mainCompositionInst = [[AVMutableVideoComposition alloc] init];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 24);
        mainCompositionInst.renderSize = CGSizeMake(self.exportVideoWidth, self.exportVideoHeight);
        
        NSString *presetName = self.exportPresetQuality==3?AVAssetExportPresetLowQuality
        :self.exportPresetQuality==1?AVAssetExportPresetHighestQuality
        :AVAssetExportPresetMediumQuality;
        
        AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
        
        [avAssetExportSession setVideoComposition:mainCompositionInst];
        [avAssetExportSession setOutputURL:output];
        [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
        if ([avAssetExportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
            [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
        }
        else{
            [avAssetExportSession setOutputFileType:[avAssetExportSession.supportedFileTypes firstObject]];
        }
        
        [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
            if (_exporttimer) {
                [_exporttimer invalidate];
                _exporttimer = nil;
            }
            
            if(avAssetExportSession.status == AVAssetExportSessionStatusCompleted)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completion(YES,output);
                }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    completion(NO,nil);
                }];
            }
            //删除临时文件
            [self deleteFiles:videoDir withExtention:@"mov"];
        }];
        
        CompressProgress progressBlock = [progress copy];
        _exporttimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                        target:self
                                                      selector:@selector(compressProgress:)
                                                      userInfo:@[avAssetExportSession,progressBlock]
                                                       repeats:YES];
    }
    
}

-(void) compressProgress:(NSTimer *)timer
{
    NSArray *array = timer.userInfo;
    AVAssetExportSession *exportSession = [array objectAtIndex:0];
    CompressProgress block = [array objectAtIndex:1];
    float progressValue = exportSession.progress;
    
    if (progressValue == 1) {
        if (_exporttimer) {
            [_exporttimer invalidate];
            _exporttimer = nil;
        }
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        block(progressValue);
    }];
}

//删除临时文件
- (void)deleteFiles:(NSString *)dir withExtention:(NSString *)ext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:dir];
    NSString *fileName;
    while (fileName= [dirEnum nextObject]) {
        if ([[fileName pathExtension] isEqualToString:ext]) {
        }
    }
}

- (void)captureCurrentVideoThumbnail
{
    if (_flags.recording) {
        [self captureVideoThumbnailAtTime:CMTimeGetSeconds(_lastTimestamp)];
    }
}

- (void)captureVideoThumbnailAtTime:(Float64)seconds
{
    [_captureThumbnailTimes addObject:@(seconds)];
}

- (void)captureVideoThumbnailAtFrame:(int64_t)frame
{
    [_captureThumbnailFrames addObject:@(frame)];
}

- (void)_generateThumbnailsForVideoWithURL:(NSURL*)url inDictionary:(NSMutableDictionary*)videoDict
{
    if (_captureThumbnailFrames.count == 0 && _captureThumbnailTimes.count == 0)
        return;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generate.appliesPreferredTrackTransform = YES;
    
    int32_t timescale = [@([self videoFrameRate]) intValue];
    
    for (NSNumber *frameNumber in [_captureThumbnailFrames allObjects]) {
        CMTime time = CMTimeMake([frameNumber longLongValue], timescale);
        Float64 timeInSeconds = CMTimeGetSeconds(time);
        [self captureVideoThumbnailAtTime:timeInSeconds];
    }
    
    NSMutableArray *captureTimes = [NSMutableArray array];
    NSArray *thumbnailTimes = [_captureThumbnailTimes allObjects];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    NSArray *sortedThumbnailTimes = [thumbnailTimes sortedArrayUsingSelector:@selector(compare:)];
#pragma clang diagnostic pop
    
    for (NSNumber *seconds in sortedThumbnailTimes) {
        CMTime time = CMTimeMakeWithSeconds([seconds doubleValue], timescale);
        [captureTimes addObject:[NSValue valueWithCMTime:time]];
    }
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    for (NSValue *time in captureTimes) {
        CGImageRef imgRef = [generate copyCGImageAtTime:[time CMTimeValue] actualTime:NULL error:NULL];
        if (imgRef) {
            UIImage *image = [[UIImage alloc] initWithCGImage:imgRef];
            if (image) {
                [thumbnails addObject:image];
            }
            CGImageRelease(imgRef);
        }
    }
    
    UIImage *defaultThumbnail = [thumbnails firstObject];
    if (defaultThumbnail) {
        [videoDict setObject:defaultThumbnail forKey:@"IPVisionVideoThumbnailKey"];
    }
    
    if (thumbnails.count) {
        [videoDict setObject:thumbnails forKey:@"IPVisionVideoThumbnailArrayKey"];
    }
}

- (void)_failVideoCaptureWithErrorCode:(NSInteger)errorCode
{
    if (errorCode && [_delegate respondsToSelector:@selector(vision:capturedVideo:error:)]) {
        NSError *error = [NSError errorWithDomain:@"IPVisionErrorDomain" code:errorCode userInfo:nil];
        [_delegate mediaCenter:self capturedVideo:nil error:error];
    }
}
- (Float64)capturedVideoSeconds{
    return CMTimeGetSeconds(_lastTimestamp);
}

#pragma mark - status

- (BOOL)supportsVideoCapture
{
    return ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0);
}

- (BOOL)canCaptureVideo
{
    BOOL isDiskSpaceAvailable = [IPVisionUtilities availableDiskSpaceInBytes] > IPVisionRequiredMinimumDiskSpaceInBytes;
    
    return [self supportsVideoCapture] && [_captureSession isRunning] && !_flags.changingModes && isDiskSpaceAvailable;
}
- (BOOL)isRecording
{
    return _flags.recording;
}

#pragma mark - Tool

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

/**
 *  获得尚未激活的摄像头
 */
- (AVCaptureDevice *)inactiveCamera
{
    AVCaptureDevice *device = nil;
    if ([self cameraCount] > 1) {
        if ([self.currentInput device].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (NSUInteger)cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)canSwitchCameras
{
    return [self cameraCount] > 1;
}

- (BOOL)swichCameras
{
    if (![self canSwitchCameras]) {
        return NO;
    }
    NSError *error;
    NSArray *inputs = self.captureSession.inputs;
    AVCaptureDeviceInput *activeDeviceInput;
    for (AVCaptureDeviceInput *input in inputs) {
        if ([input isEqual:_captureDeviceInputBack] || [input isEqual:_captureDeviceInputFront]) {
            activeDeviceInput = input;
            break;
        }
    }
    if (activeDeviceInput) {
        AVCaptureDeviceInput *inactiveDeviceInput = [activeDeviceInput isEqual:_captureDeviceInputBack] ? _captureDeviceInputFront :_captureDeviceInputBack;
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:activeDeviceInput];
        
        if ([self.captureSession canAddInput:inactiveDeviceInput]) {
            [self.captureSession addInput:inactiveDeviceInput];
            self.currentInput = inactiveDeviceInput;
        }else {
            [self.captureSession addInput:activeDeviceInput];
        }
        
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    
    return YES;
}

@end
