//
//  IPTakeMediaOverLayerView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2019/5/7.
//  Copyright © 2019 JL. All rights reserved.
//

#import "IPTakeMediaOverLayerView.h"

@interface IPTakeMediaOverLayerView()

@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIButton *takePictureButton;
@property (nonatomic, strong)UIImageView *imageLibraryView;
@property (nonatomic, strong)UIView   *bottomBar;

@property (nonatomic, strong)UIImageView   *focusView;

@property (nonatomic, strong)UIButton *flashButton;
@property (nonatomic, strong)UIButton *flashAutoButton;
@property (nonatomic, strong)UIButton *flashOpenButton;
@property (nonatomic, strong)UIButton *flashCloseButton;

@property (nonatomic, strong)UIButton *cameraSwitchButton;
@property (nonatomic, strong)UIView   *topbar;

@property (nonatomic, assign)BOOL      isHiddenFlashButtons;

@end

@implementation IPTakeMediaOverLayerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self _initlize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self _initlize];
    }
    return self;
}

- (void)_initlize
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    [self addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.cancelButton];
    [self.bottomBar addSubview:self.takePictureButton];
    [self addSubview:self.topbar];
    [self.topbar addSubview:self.cameraSwitchButton];
    [self.topbar addSubview:self.flashButton];
    [self.topbar addSubview:self.flashAutoButton];
    [self.topbar addSubview:self.flashOpenButton];
    [self.topbar addSubview:self.flashCloseButton];
    
    [self addSubview:self.focusView];
    
    [self reSetTopbar];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _topbar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 64);
    _bottomBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 64, CGRectGetWidth(self.bounds), 64);
    
    _flashButton.frame = CGRectMake(10, 11, 40, 40);
    _flashButton.center = CGPointMake(_flashButton.center.x, CGRectGetHeight(_topbar.bounds) / 2.0);
    
    CGRect flashAutoButtonFram = _flashAutoButton.frame;
    flashAutoButtonFram.size = CGSizeMake(60, CGRectGetHeight(_topbar.frame));
    flashAutoButtonFram.origin.x = CGRectGetMaxX(_flashButton.frame) + 20;
    _flashAutoButton.center = CGPointMake(_flashAutoButton.center.x, CGRectGetHeight(_topbar.bounds) / 2.0);
    _flashAutoButton.frame = flashAutoButtonFram;
    
    CGRect flashOpeanButtonFrame = _flashOpenButton.frame;
    flashOpeanButtonFrame.size = CGSizeMake(60, CGRectGetHeight(_topbar.frame));
    flashOpeanButtonFrame.origin.x = CGRectGetMaxX(_flashAutoButton.frame) + 20;
    _flashOpenButton.center = CGPointMake(_flashOpenButton.center.x, CGRectGetHeight(_topbar.bounds) / 2.0);
    _flashOpenButton.frame = flashOpeanButtonFrame;
    
    
    CGRect flashCloseButtonFrame = _flashCloseButton.frame;
    flashCloseButtonFrame.size = CGSizeMake(60, CGRectGetHeight(_topbar.frame));
    flashCloseButtonFrame.origin.x = CGRectGetMaxX(_flashOpenButton.frame) + 20;
    _flashCloseButton.center = CGPointMake(_flashCloseButton.center.x, CGRectGetHeight(_topbar.bounds) / 2.0);
    _flashCloseButton.frame = flashCloseButtonFrame;
    
    
    _cameraSwitchButton.frame =  CGRectMake(CGRectGetWidth(self.bounds) - 40, 7, 30, 25);
    _cameraSwitchButton.center = CGPointMake(_cameraSwitchButton.center.x, CGRectGetHeight(_topbar.bounds) / 2.0);
    
    
    _takePictureButton.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2.0 - 30, 7.5, 55, 55);
    _takePictureButton.center = CGPointMake(_takePictureButton.center.x, CGRectGetHeight(_bottomBar.bounds) / 2.0);
    
    _cancelButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 70, 0, 55, 55);
    _cancelButton.center = CGPointMake(_cancelButton.center.x, CGRectGetHeight(_bottomBar.bounds) / 2.0);
    
    _imageLibraryView.frame = CGRectMake(10, 0, 55, 55);
    _imageLibraryView.center = CGPointMake(_imageLibraryView.center.x, CGRectGetHeight(_bottomBar.bounds) / 2.0);
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super hitTest:point withEvent:event];
}

- (void)reSetTopbar
{
    self.isHiddenFlashButtons = YES;
    _flashOpenButton.hidden = YES;
    _flashCloseButton.hidden = YES;
    _flashAutoButton.hidden  = YES;
    _cameraSwitchButton.hidden = NO;
}

- (void)setFlashModel:(AVCaptureFlashMode)mode{
    if(mode == AVCaptureFlashModeOff){
        [self.flashCloseButton setTitleColor:[UIColor colorWithRed:252/255.0 green:149/255.0 blue:73/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_c"] forState:UIControlStateNormal];
    }else if (mode == AVCaptureFlashModeOn){
        [self.flashOpenButton setTitleColor:[UIColor colorWithRed:252/255.0 green:149/255.0 blue:73/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_n"] forState:UIControlStateNormal];
    }else if (mode == AVCaptureFlashModeAuto){
        [self.flashAutoButton setTitleColor:[UIColor colorWithRed:252/255.0 green:149/255.0 blue:73/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_o"] forState:UIControlStateNormal];
    }
}

- (void)chosedFlashButton:(UIButton *)btn{
    [btn setTitleColor:[UIColor colorWithRed:252/255.0 green:149/255.0 blue:73/255.0 alpha:1.0] forState:UIControlStateNormal];
    if([btn.titleLabel.text isEqualToString:@"自动"]){
        [self.flashCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashOpenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_o"] forState:UIControlStateNormal];
    }
    else if ([btn.titleLabel.text isEqualToString:@"打开"])
    {
        [self.flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_n"] forState:UIControlStateNormal];
    }
    else if ([btn.titleLabel.text isEqualToString:@"关闭"])
    {
        [self.flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashOpenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashButton setImage:[UIImage imageNamed:@"camera_light_c"] forState:UIControlStateNormal];
    }
}

#pragma mark Private Methods
- (void)hiddenSelfAndBars:(BOOL)hidden{
    self.hidden = hidden;
    self.topbar.hidden = hidden;
    self.bottomBar.hidden = hidden;
}

- (void)_setFlashButtonsHidden{
    self.isHiddenFlashButtons = NO;
    _flashOpenButton.hidden = NO;
    _flashAutoButton.hidden = NO;
    _flashCloseButton.hidden = NO;
}

#pragma Actions
- (void)flashButtonClick:(id )sender
{
    if(self.isHiddenFlashButtons){
        [self _setFlashButtonsHidden];
        _cameraSwitchButton.hidden = YES;
    }else{
        [self reSetTopbar];
    }
}

#pragma mark - setters && getters
- (UIView *)bottomBar{
    if(_bottomBar == nil){
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _bottomBar;
}

- (UIButton *)cancelButton{
    if(_cancelButton == nil){
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setTextColor:[UIColor whiteColor]];
    }
    return _cancelButton;
}

- (UIButton *)takePictureButton{
    if(_takePictureButton == nil){
        _takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePictureButton setImage:[UIImage imageNamed:@"camera_Photo"] forState:UIControlStateNormal];
        [_takePictureButton.titleLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _takePictureButton;
}

- (UIImageView *)imageLibraryView{
    if(_imageLibraryView == nil){
        _imageLibraryView = [[UIImageView alloc] init];
        _imageLibraryView.userInteractionEnabled = YES;
        [_bottomBar addSubview:_imageLibraryView];
    }
    
    return _imageLibraryView;
}

- (UIView *)topbar{
    if(_topbar == nil){
        _topbar = [[UIView alloc] init];
        _topbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    
    return _topbar;
}

- (UIButton *)flashButton{
    if(_flashButton == nil){
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setImage:[UIImage imageNamed:@"camera_light_c"]
                      forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashButtonClick:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _flashButton;
}

- (UIButton *)flashAutoButton{
    if(_flashAutoButton == nil){
        _flashAutoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashAutoButton setTitle:@"自动" forState:UIControlStateNormal];
        [_flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _flashAutoButton;
    
}

- (UIButton *)flashOpenButton{
    if(_flashOpenButton == nil){
        _flashOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashOpenButton setTitle:@"打开" forState:UIControlStateNormal];
        [_flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _flashOpenButton;
    
}

- (UIButton *)flashCloseButton{
    if(_flashCloseButton == nil){
        _flashCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashCloseButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    
    return _flashCloseButton;
    
}

- (UIButton *)cameraSwitchButton{
    if(_cameraSwitchButton == nil){
        _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    }
    
    return _cameraSwitchButton;
    
}

- (UIImageView *)focusView{
    if(_focusView == nil){
        _focusView = [[UIImageView alloc] init];
        _focusView.frame = CGRectMake(0, 0, 80, 80);
        _focusView.layer.borderColor = [UIColor colorWithRed:252/255.0 green:208/255.0 blue:52/255.0 alpha:1.0].CGColor;
        _focusView.layer.borderWidth = 2.0f;
        _focusView.hidden = YES;
        _focusView.alpha = 0.0;
    }
    
    return _focusView;
}

@end
