//
//  IPTakePhotoViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPTakePhotoViewController.h"
#import "IPMediaCenter.h"
#import "IPPrivateDefine.h"
#import "IPTakeMediaOverLayerView.h"
#import "IPImagePickerPreImageView.h"

@interface IPTakePhotoViewController ()

/**拍照出的照片*/
@property (nonatomic, weak)IPImagePickerPreImageView *capturePhotoImgView;

@property (nonatomic, strong)IPTakeMediaOverLayerView *preview;

@end

@implementation IPTakePhotoViewController

- (void)dealloc
{
    IPLog(@"IPTakePhotoViewController dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.preview = [[IPTakeMediaOverLayerView alloc]initWithFrame:self.view.bounds];
    self.preview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.preview];
    
    AVCaptureVideoPreviewLayer *previewLayer = [IPMediaCenter defaultCenter].previewLayer;
    if (previewLayer.superlayer) {
        [previewLayer removeFromSuperlayer];
    }
    previewLayer.frame = self.preview.bounds;
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.preview.layer insertSublayer:previewLayer atIndex:0];
    
    IPImagePickerPreImageView *imgView = [[IPImagePickerPreImageView alloc]initWithFrame:self.view.bounds];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imgView];
    imgView.hidden = YES;
    self.capturePhotoImgView = imgView;
    
    [self.preview.cancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.preview.cameraSwitchButton addTarget:self action:@selector(switchCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.preview.takePictureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.capturePhotoImgView.reTakeButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.capturePhotoImgView.useImageButton addTarget:self action:@selector(usePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - btn_click

- (void)back
{
    if ([_delegate respondsToSelector:@selector(didClickCancelBtnInTakePhotoViewController:)]) {
        [_delegate didClickCancelBtnInTakePhotoViewController:self];
    }
}

- (void)switchCameraBtnClick
{
    [[IPMediaCenter defaultCenter] swichCameras];
}

- (void)takePhoto:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    
    __weak typeof(self)weakSelf = self;
    [[IPMediaCenter defaultCenter] captureStillImage:^(UIImage *image) {
        
        weakSelf.capturePhotoImgView.imageView.image = image;
        weakSelf.capturePhotoImgView.hidden = NO;
        
        [weakSelf.preview hiddenSelfAndBars:YES];
        
    }];
}

- (void)cancelBtnClick:(UIButton *)sender
{
    _capturePhotoImgView.imageView.image = nil;
    _capturePhotoImgView.hidden = YES;
    
    [self.preview hiddenSelfAndBars:NO];
    
    self.preview.takePictureButton.userInteractionEnabled = YES;
}

- (void)usePhotoBtnClick:(UIButton *)sender
{
    self.preview.takePictureButton.userInteractionEnabled = YES;
    if ([self.delegate respondsToSelector:@selector(takePhotoViewController:takeImage:)]) {
        [self.delegate takePhotoViewController:self takeImage:self.capturePhotoImgView.imageView.image];
    }
}

#pragma mark - statusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
