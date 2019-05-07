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

@interface IPTakePhotoViewController ()
/**头部标题*/
@property (nonatomic, weak)UIView *headerBGView;

/**返回btn*/
@property (nonatomic, weak)UIButton *leftButton;


/**底部标题*/
@property (nonatomic, weak)UIView *bottomBGView;

@property (nonatomic, weak)UIButton *takePhotoBtn;

@property (nonatomic, weak)UIButton *cancelBtn;

@property (nonatomic, weak)UIButton *usePhotoBtn;

/**拍照出的照片*/
@property (nonatomic, weak)UIImageView *capturePhotoImgView;

@end

@implementation IPTakePhotoViewController

- (void)dealloc{
    IPLog(@"IPTakePhotoViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addMainView];
    [self addHeaderView];
    [self addBottomView];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imgView belowSubview:_bottomBGView];
    imgView.hidden = YES;
    self.capturePhotoImgView = imgView;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)addMainView{
    AVCaptureVideoPreviewLayer *previewLayer = [IPMediaCenter defaultCenter].previewLayer;
    if (previewLayer.superlayer) {
        [previewLayer removeFromSuperlayer];
    }
    previewLayer.frame = self.view.bounds;
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
}
- (void)addBottomView{
    
    UIView *bottomBGView = [[UIView alloc]init];
    bottomBGView.backgroundColor = [UIColor colorWithRed:0 green:0  blue:0 alpha:0.5];
    [self.view addSubview:bottomBGView];
    self.bottomBGView = bottomBGView;
    
    
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image =[UIImage imageNamed:@"icon_fabu_take_photo"];
    [takePhotoBtn setImage:image forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBGView addSubview:takePhotoBtn];
    self.takePhotoBtn = takePhotoBtn;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBGView addSubview:cancelBtn];
    cancelBtn.hidden = YES;
    self.cancelBtn = cancelBtn;
    
    UIButton *usePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [usePhotoBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    [usePhotoBtn addTarget:self action:@selector(usePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    usePhotoBtn.hidden = YES;
    [bottomBGView addSubview:usePhotoBtn];
    self.usePhotoBtn = usePhotoBtn;
    
}
- (void)addHeaderView{
    
    //添加背景图
    UIView *headerBGView = [[UIView alloc]init];
    headerBGView.backgroundColor = [UIColor colorWithRed:0 green:0  blue:0 alpha:0.5];
    
    [self.view addSubview:headerBGView];
    self.headerBGView = headerBGView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *leftBtnImage =[UIImage imageNamed:@"bar_btn_icon_returntext_white"];
    [leftBtn setImage:leftBtnImage forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.headerBGView addSubview:leftBtn];
    self.leftButton = leftBtn;
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
//    UIImage *image =[UIImage imageNamed:@"img_icon_check_Big"];
//    UIImage *image_p =[UIImage imageNamed:@"img_icon_check_Big_p"];
//    [rightBtn setImage:image forState:UIControlStateNormal];
//    [rightBtn setImage:image_p forState:UIControlStateSelected];
//    [rightBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.headerView addSubview:rightBtn];
//    self.rightButton = rightBtn;
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [[IPMediaCenter defaultCenter]startPreview];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[IPMediaCenter defaultCenter]stopPreview];
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerBGView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20 + 44);
    self.leftButton.frame = CGRectMake(-5, 20, 44, 44);
    
    self.bottomBGView.frame = CGRectMake(0, self.view.bounds.size.height - 64, self.view.bounds.size.width, 64);
    
    self.takePhotoBtn.frame = CGRectMake(0, 0, 44, 44);
    self.takePhotoBtn.center = CGPointMake(_bottomBGView.center.x, 32);
    
    _capturePhotoImgView.frame = self.view.bounds;
    
    _cancelBtn.frame = CGRectMake(20, 0, 44, 64);
    _usePhotoBtn.frame = CGRectMake(self.view.bounds.size.width - 20 - 88, 0, 88, 64);
}
#pragma mark - btn_click
- (void)back{
    if ([_delegate respondsToSelector:@selector(didClickCancelBtnInTakePhotoViewController:)]) {
        [_delegate didClickCancelBtnInTakePhotoViewController:self];
    }
    
}
- (void)takePhoto:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    
    __weak typeof(self)weakSelf = self;
    [[IPMediaCenter defaultCenter] captureStillImage:^(UIImage *image) {
        
        weakSelf.capturePhotoImgView.image = image;
        weakSelf.capturePhotoImgView.hidden = NO;
        
        weakSelf.takePhotoBtn.hidden = YES;
        weakSelf.cancelBtn.hidden = NO;
        weakSelf.usePhotoBtn.hidden = NO;
        
    }];
}
- (void)cancelBtnClick:(UIButton *)sender{
    _capturePhotoImgView.image = nil;
    _capturePhotoImgView.hidden = YES;
    sender.hidden = YES;
    _usePhotoBtn.hidden = YES;
    _takePhotoBtn.hidden = NO;
    _takePhotoBtn.userInteractionEnabled = YES;
}
- (void)usePhotoBtnClick:(UIButton *)sender{
    
}

#pragma mark - statusBar
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
