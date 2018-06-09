//
//  IPImageReaderCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPImageReaderCell.h"
#import "UICollectionViewCell+PhotoReader.h"
#import "IPAssetManager.h"
#import "IPImageReaderViewController.h"
#import "IPImageReaderViewController+AniamtionTranstion.h"
#import "IPPrivateDefine.h"

@interface IPImageReaderCell ()<
    UIScrollViewDelegate
>

{
    
    //动画相关
    CGFloat startScaleWidthInAnimationView; //开始拖动时比例
    CGFloat startScaleheightInAnimationView;    //开始拖动时比例
    CGRect frameOfOriginalOfImageView;  //开始拖动时图片frame
    CGPoint startOffsetOfScrollView;    //开始拖动时scrollview的偏移
    CGFloat lastPointX; //上一次触摸点x值
    CGFloat lastPointY; //上一次触摸点y值
    CGFloat totalOffsetXOfAnimateImageView; //总共的拖动偏移x
    CGFloat totalOffsetYOfAnimateImageView; //总共的拖动偏移y
    BOOL animateImageViewIsStart;   //拖动动效是否第一次触发
    BOOL isCancelAnimate;   //正在取消拖动动效
}

@property (nonatomic, strong)UIScrollView *zoomScroll;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImageView *dismissAnimateImageView;    //做动画的图片

@property (nonatomic, strong) NSString *imgSourceUrl;
@property (nonatomic, strong) id asset;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL cancelDragImageViewAnimation;
@property (nonatomic, assign) CGFloat outScaleOfDragImageViewAnimation;

@end

@implementation IPImageReaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // Configure the cell
        self.backgroundColor = [UIColor clearColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.zoomScroll];
        [self.contentView addSubview:self.photoImageView];
        if (@available(iOS 11.0, *)) {
            self.zoomScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addGesture];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.zoomScroll setZoomScale:1.0 animated:NO];
    self.photoImageView.image = nil;
    self.photoImageView.hidden = YES;
    self.photoImageView.image = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.zoomScroll.frame = self.bounds;
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter)){
        _photoImageView.frame = frameToCenter;
    }
}

- (UIScrollView *)zoomScroll
{
    if (_zoomScroll == nil) {
        _zoomScroll = [[UIScrollView alloc]initWithFrame:self.bounds];
        _zoomScroll.backgroundColor = [UIColor clearColor];
        _zoomScroll.delegate = self;
        _zoomScroll.showsHorizontalScrollIndicator = NO;
        _zoomScroll.showsVerticalScrollIndicator = NO;
        _zoomScroll.alwaysBounceVertical = YES;
        _zoomScroll.alwaysBounceHorizontal = YES;
        _zoomScroll.decelerationRate = UIScrollViewDecelerationRateFast;
        _zoomScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _zoomScroll;
}

- (UIImageView *)dismissAnimateImageView
{
    if (!_dismissAnimateImageView) {
        _dismissAnimateImageView = [UIImageView new];
        _dismissAnimateImageView.contentMode = UIViewContentModeScaleAspectFill;
        _dismissAnimateImageView.layer.masksToBounds = YES;
    }
    return _dismissAnimateImageView;
}

- (UIImageView *)photoImageView
{
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.backgroundColor = [UIColor clearColor];
    }
    return _photoImageView;
}


- (void)addGesture
{
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapDouble.numberOfTapsRequired = 2;
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:tapSingle];
    [self addGestureRecognizer:tapDouble];
    [self addGestureRecognizer:longPress];
}



- (void)displayImageWithFullScreenImage
{
    CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        size = CGSizeMake(self.bounds.size.height, self.bounds.size.width);
    }
    
    [[IPAssetManager defaultAssetManager] getFullScreenImageWithMutipleAsset:_asset photoWidth:size completion:^(UIImage *img, NSDictionary *info) {
        if (img) {
            if (!CGSizeEqualToSize(img.size, _photoImageView.image.size)) {
                // Set image
                _photoImageView.image = img;
                _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                // Setup photo frame
                self.zoomScroll.contentSize = _photoImageView.frame.size;
                
                [self setMaxMinZoomScalesForCurrentBounds];
                [self setNeedsLayout];
            }
            
        }
    }];
}

- (void)displayImageWithImageUrl:(NSString *)imageURL
{
    _imgSourceUrl = imageURL;
    CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        size = CGSizeMake(self.bounds.size.height, self.bounds.size.width);
    }
    [IPAssetManager getImageWithImageURL:imageURL width:size.width RequestBlock:^(UIImage *image, NSError *error) {
        if (!error && image) {
            [self displayImageWithImage:image];
        }
    }];
}

- (void)displayImageWithImage:(UIImage *)image
{
    // Reset
    self.zoomScroll.maximumZoomScale = 1;
    self.zoomScroll.minimumZoomScale = 1;
    self.zoomScroll.zoomScale = 1;
    
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    // Set image
    _photoImageView.image = image;
    _photoImageView.hidden = NO;

    // Setup photo frame
    CGRect photoImageViewFrame;
    
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        CGFloat height = self.bounds.size.height;
        
        CGFloat width = height * image.size.width /image.size.height;
        photoImageViewFrame.size = CGSizeMake(width, height);

    }else {
        
        CGFloat width = self.bounds.size.width;
        
        CGFloat height = width * image.size.height /image.size.width;
        photoImageViewFrame.size = CGSizeMake(width, height);
        
    }
    photoImageViewFrame.origin = CGPointZero;
    _photoImageView.frame = photoImageViewFrame;
    [self setNeedsLayout];
}

- (void)displayImageWithAlbumAsset:(id)asset
{
    CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        size = CGSizeMake(self.bounds.size.height, self.bounds.size.width);
    }
    _asset = asset;
    [[IPAssetManager defaultAssetManager] getHighQualityImageWithMutipleAsset:asset photoWidth:size completion:^(UIImage *photo, NSDictionary *info) {
        if (photo) {
            [self displayImageWithImage:photo];
        }
    }];
}

//设置当前情况下,最大和最小伸缩比
- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.zoomScroll.maximumZoomScale = 1;
    self.zoomScroll.minimumZoomScale = 1;
    self.zoomScroll.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.zoomScroll.maximumZoomScale = maxScale;
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    //    self.scrollEnabled = NO;
    
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.zoomScroll.minimumZoomScale;
    if (_photoImageView ) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.zoomScroll.minimumZoomScale, zoomScale), self.zoomScroll.maximumZoomScale);
        }
    }
    return zoomScale;
}



#pragma mark - Layout


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.zoomScroll.scrollEnabled = YES; // reset
    
    [self panDismissRecordInfoWithScrollView:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomScroll.scrollEnabled = YES; // reset
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self panDismissRemoveAnimationImageViewWithScrollView:scrollView container:self];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self panDismissRespondsToScrollViewPanGesture];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - dragAnimation
- (void)panDismissRecordInfoWithScrollView:(UIScrollView *)scrollView {
    if (self.cancelDragImageViewAnimation) return;
    
    CGPoint point = [scrollView.panGestureRecognizer locationInView:self];
    startOffsetOfScrollView = scrollView.contentOffset;
    frameOfOriginalOfImageView = [self.photoImageView convertRect:self.photoImageView.bounds toView:self.window];
    startScaleWidthInAnimationView = (point.x - frameOfOriginalOfImageView.origin.x) / frameOfOriginalOfImageView.size.width;
    startScaleheightInAnimationView = (point.y - frameOfOriginalOfImageView.origin.y) / frameOfOriginalOfImageView.size.height;
}

- (void)panDismissRespondsToScrollViewPanGesture {
    if (self.cancelDragImageViewAnimation || self.zoomScroll.isZooming) return;
    
    UIPanGestureRecognizer *pan = self.zoomScroll.panGestureRecognizer;
    if (pan.numberOfTouches != 1) return;
    
    CGPoint point = [pan locationInView:self];
    BOOL shouldAddAnimationView = point.y > lastPointY && self.zoomScroll.contentOffset.y < -10 && !self.dismissAnimateImageView.superview;
    if (shouldAddAnimationView) {
        [self panDismissAddAnimationImageViewWithPoint:point];
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        [self panDismissPerformAnimationForAnimationImageViewWithPoint:point container:self];
    }
    
    lastPointY = point.y;
    lastPointX = point.x;
}

- (void)panDismissAddAnimationImageViewWithPoint:(CGPoint)point {
    if (self.photoImageView.frame.size.width <= 0 || self.photoImageView.frame.size.height <= 0) return;
    
    //    if (!YBImageBrowser.isControllerPreferredForStatusBar) [[UIApplication sharedApplication] setStatusBarHidden:YBImageBrowser.statusBarIsHideBefore];
    
    [self.readerVc photoReaderHideReaderView];

    
    animateImageViewIsStart = YES;
    totalOffsetYOfAnimateImageView = 0;
    totalOffsetXOfAnimateImageView = 0;
    self.dismissAnimateImageView.image = self.photoImageView.image;
    self.dismissAnimateImageView.frame = frameOfOriginalOfImageView;
    [self.window addSubview:self.dismissAnimateImageView];
}

- (void)panDismissRemoveAnimationImageViewWithScrollView:(UIScrollView *)scrollView container:(UIView *)container {
    if (!self.dismissAnimateImageView.superview) return;
    
    CGFloat maxHeight = container.bounds.size.height;
    if (maxHeight <= 0) return;
    if (scrollView.zoomScale <= 1) {
        scrollView.contentOffset = CGPointZero;
    }
    
    if (totalOffsetYOfAnimateImageView > maxHeight * 0.15) {
        //移除图片浏览器
        [self.readerVc dismissViewController];
    } else {
        
        //复位
        if (isCancelAnimate) return;
        isCancelAnimate = YES;
        
        CGFloat duration = 0.25;
        [self.readerVc photoReadeWillShowWithTimeInterval:duration];
        
        [UIView animateWithDuration:duration animations:^{
            self.dismissAnimateImageView.frame = frameOfOriginalOfImageView;
        } completion:^(BOOL finished) {
            
            //电池条处理 TODO
            self.zoomScroll.contentOffset = self->startOffsetOfScrollView;
            
            [self.readerVc photoReaderShowReaderView];
            [self.dismissAnimateImageView removeFromSuperview];
            self->isCancelAnimate = NO;
        }];
    }
}

- (void)panDismissPerformAnimationForAnimationImageViewWithPoint:(CGPoint)point container:(UIView *)container {
    if (!self.dismissAnimateImageView.superview) {
        return;
    }
    
    CGFloat maxHeight = container.bounds.size.height;
    if (maxHeight <= 0) return;
    //偏移
    CGFloat offsetX = point.x - lastPointX,
    offsetY = point.y - lastPointY;
    if (animateImageViewIsStart) {
        offsetX = offsetY = 0;
        animateImageViewIsStart = NO;
    }
    totalOffsetXOfAnimateImageView += offsetX;
    totalOffsetYOfAnimateImageView += offsetY;
    //缩放比例
    CGFloat scale = (1 - totalOffsetYOfAnimateImageView / maxHeight);
    if (scale > 1) scale = 1;
    if (scale < 0) scale = 0;
    //执行变换
    CGFloat width = frameOfOriginalOfImageView.size.width * scale, height = frameOfOriginalOfImageView.size.height * scale;
    self.dismissAnimateImageView.frame = CGRectMake(point.x - width * startScaleWidthInAnimationView, point.y - height * startScaleheightInAnimationView, width, height);
    
    [self.readerVc photoReadeViewChangeBackgroundAlphaWithScale:scale];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Zoom
    if (self.zoomScroll.zoomScale != self.zoomScroll.minimumZoomScale && self.zoomScroll.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self.zoomScroll setZoomScale:self.zoomScroll.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.zoomScroll.maximumZoomScale + self.zoomScroll.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self.zoomScroll zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
    }
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    
}



#pragma mark - UICollectionViewCell (PhotoReader)

- (UIImageView *)animateImageView
{
    return self.dismissAnimateImageView;
}

- (UIImageView *)sourceImageView
{
    return self.photoImageView;
}

@end

