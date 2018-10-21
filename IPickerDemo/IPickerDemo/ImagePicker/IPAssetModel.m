//
//  IPAssetModel.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAssetModel.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface IPAssetModel() {
    PHImageRequestID _assetRequestID;
    PHImageRequestID _assetVideoRequestID;
//    id <SDWebImageOperation> _webImageOperation;
    
    BOOL _loadingAssetInProgress;
    id _webImageOperation;
}

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *fullScreenImage;
@property (nonatomic) CGSize assetTargetSize;

@end

@implementation IPAssetModel
@synthesize underlyingImage = _underlyingImage; // synth property from protocol
@synthesize isVideo;

#pragma mark - class

+ (IPAssetModel *)assetModelWithImage:(UIImage *)image
{
    return [[self alloc] initWithImage:image];
}

+ (IPAssetModel *)assetModelWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

+ (IPAssetModel *)assetModelWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize
{
    return [[self alloc] initWithAsset:asset targetSize:targetSize];
}

+ (IPAssetModel *)videoWithURL:(NSURL *)url
{
    return [[self alloc] initWithVideoURL:url];
}

#pragma mark - Init

- (instancetype)init
{
    if ((self = [super init])) {
        self.emptyImage = YES;
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if ((self = [super init])) {
        self.image = image;
        [self setup];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
{
    if ((self = [super init])) {
        self.photoURL = url;
        [self setup];
    }
    return self;
}

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize
{
    if ((self = [super init])) {
        self.asset = asset;
        self.assetTargetSize = targetSize;
        self.isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        [self setup];
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)url
{
    if ((self = [super init])) {
        self.videoURL = url;
        self.isVideo = YES;
        self.emptyImage = YES;
        [self setup];
    }
    return self;
}

- (void)setup {
    _assetRequestID = PHInvalidImageRequestID;
    _assetVideoRequestID = PHInvalidImageRequestID;
}


- (void)dealloc
{
    [self cancelAnyLoading];
}

#pragma mark - cancel

- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingAssetInProgress = NO;
    }
    [self cancelImageRequest];
    [self cancelVideoRequest];
}

- (void)cancelImageRequest {
    if (_assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetRequestID];
        _assetRequestID = PHInvalidImageRequestID;
    }
}

- (void)cancelVideoRequest {
    if (_assetVideoRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetVideoRequestID];
        _assetVideoRequestID = PHInvalidImageRequestID;
    }
}


#pragma mark - IPAssetModelProtocol Methods

- (void)loadFullScreenImageAndComplete:(void(^)(BOOL success,UIImage *image))complete
{
//    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
//    if (_loadingAssetInProgress) return;
//    _loadingAssetInProgress = YES;
//    @try {
//        if (self.fullScreenImage) {
//            if (complete) {
//                _loadingAssetInProgress = NO;
//                complete(YES,self.fullScreenImage);
//            }
//        } else {
//            [self performLoadFullScreenImageAndComplete:complete];
//        }
//    }
//    @catch (NSException *exception) {
//        self.fullScreenImage = nil;
//        _loadingAssetInProgress = NO;
//        if (complete) {
//            complete(NO,nil);
//        }
//    }
//    @finally {
//    }
}

- (void)performLoadFullScreenImageAndComplete:(void(^)(BOOL success,UIImage *image))complete
{
    if (_asset) {
        
        // Load from photos asset
        [self _performLoadFullScreenImageWithAsset: _asset targetSize:_assetTargetSize complete:complete];
        
    }
}

- (void)unloadFullScreenImage
{
    
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingAssetInProgress = NO;
    self.underlyingImage = nil;
}

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndComplete:(void(^)(BOOL success,UIImage *image))complete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingAssetInProgress) return;
    _loadingAssetInProgress = YES;
    @try {
        if (self.underlyingImage) {
            if (complete) {
                _loadingAssetInProgress = NO;
                complete(YES,self.underlyingImage);
            }
        } else {
            [self performLoadUnderlyingImageAndComplete:complete];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingAssetInProgress = NO;
        if (complete) {
            complete(NO,nil);
        }
    }
    @finally {
    }
}



// Set the underlyingImage
- (void)performLoadUnderlyingImageAndComplete:(void (^)(BOOL success, UIImage *image))complete {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        if (complete) {
            _loadingAssetInProgress = NO;
            complete(YES,self.underlyingImage);
        }
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            
            // Load from assets library
            [self _performLoadUnderlyingImageWithAssetsLibraryURL: _photoURL complete:complete];
            
        } else if ([_photoURL isFileReferenceURL]) {
            
            // Load from local file async
            [self _performLoadUnderlyingImageWithLocalFileURL: _photoURL complete:complete];
            
        } else {
            
            // Load async from web (using SDWebImage)
            [self _performLoadUnderlyingImageWithWebURL: _photoURL complete:complete];
            
        }
        
    } else if (_asset) {
        
        // Load from photos asset
        [self _performLoadUnderlyingImageWithAsset: _asset targetSize:_assetTargetSize complete:complete];
        
    } else {
        
        // Image is empty
        if (complete) {
            _loadingAssetInProgress = NO;
            complete(NO,nil);
        }
    }
}

#pragma mark - private

// Load from local file
- (void)_performLoadUnderlyingImageWithWebURL:(NSURL *)url complete:(void (^)(BOOL success, UIImage *image))complete{
//    @try {
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        _webImageOperation = [manager downloadImageWithURL:url
//                                                   options:0
//                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                                      if (expectedSize > 0) {
//                                                          float progress = receivedSize / (float)expectedSize;
//                                                          NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                                                [NSNumber numberWithFloat:progress], @"progress",
//                                                                                self, @"photo", nil];
//                                                          [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
//                                                      }
//                                                  }
//                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                                     if (error) {
//                                                         MWLog(@"SDWebImage failed to download image: %@", error);
//                                                     }
//                                                     _webImageOperation = nil;
//                                                     self.underlyingImage = image;
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                                         [self imageLoadingComplete];
//                                                     });
//                                                 }];
//    } @catch (NSException *e) {
//        MWLog(@"Photo from web: %@", e);
//        _webImageOperation = nil;
//        [self imageLoadingComplete];
//    }
}


// Load from local file
- (void)_performLoadUnderlyingImageWithLocalFileURL:(NSURL *)url complete:(void (^)(BOOL success, UIImage *image))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                self.underlyingImage = [UIImage imageWithContentsOfFile:url.path];
                if (!_underlyingImage) {
                    NSLog(@"Error loading photo from path: %@", url.path);
                    if (complete) {
                        _loadingAssetInProgress = NO;
                        complete(NO,nil);
                    }
                } else {
                    if (complete) {
                        _loadingAssetInProgress = NO;
                        complete(YES,self.underlyingImage);
                    }
                }
            } @finally {
                if (complete) {
                    _loadingAssetInProgress = NO;
                    complete(NO,nil);
                }
            }
        }
    });
}

// Load from asset library async
- (void)_performLoadUnderlyingImageWithAssetsLibraryURL:(NSURL *)url complete:(void (^)(BOOL success, UIImage *image))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:url
                               resultBlock:^(ALAsset *asset){
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.underlyingImage = [UIImage imageWithCGImage:iref];
                                   }
                                   if (complete) {
                                       _loadingAssetInProgress = NO;
                                       complete(YES,self.underlyingImage);
                                   }
                               }
                              failureBlock:^(NSError *error) {
                                  self.underlyingImage = nil;
                                  NSLog(@"Photo from asset library error: %@",error);
                                  if (complete) {
                                      _loadingAssetInProgress = NO;
                                      complete(NO,nil);
                                  }
                              }];
            } @catch (NSException *e) {
                NSLog(@"Photo from asset library error: %@", e);
                if (complete) {
                    _loadingAssetInProgress = NO;
                    complete(NO,nil);
                }
            }
        }
    });
}

// Load from photos library
- (void)_performLoadUnderlyingImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize  complete:(void (^)(BOOL success, UIImage *image))complete
{
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithDouble: progress], @"progress",
//                              self, @"photo", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
    };
    
    _assetRequestID = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.underlyingImage = result;
            if (complete) {
                _loadingAssetInProgress = NO;
                complete(YES,self.underlyingImage);
            }
        });
    }];
    
}

- (void)_performLoadFullScreenImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize  complete:(void (^)(BOOL success, UIImage *image))complete
{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    PHAsset *phAsset = asset;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //                IPLog(@"高清图--%@",info);
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined) {
                _loadingAssetInProgress = NO;
                self.fullScreenImage = result;
                complete(downloadFinined,result);
                
            }else {
                complete(nil,nil);
            }
        });
        
    }];
}

@end
