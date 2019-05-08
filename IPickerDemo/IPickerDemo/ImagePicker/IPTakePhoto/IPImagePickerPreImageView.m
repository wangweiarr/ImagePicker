//
//  IPImagePickerPreImageView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2019/5/8.
//  Copyright © 2019 JL. All rights reserved.
//

#import "IPImagePickerPreImageView.h"

@implementation IPImagePickerPreImageView

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
    [self addSubview:self.imageView];
    [self addSubview:self.reTakeButton];
    [self addSubview:self.useImageButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.imageView.frame = CGRectMake(0, 70, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 70 - 90);
    self.reTakeButton.frame = CGRectMake(10, CGRectGetHeight(self.bounds) - 80, 60, 60);
    self.useImageButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 90, CGRectGetHeight(self.bounds) - 80, 80, 60);
    
}

- (UIButton *)reTakeButton
{
    if(_reTakeButton == nil){
        _reTakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reTakeButton setTitle:@"重拍" forState:UIControlStateNormal];
        [_reTakeButton.titleLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _reTakeButton;
}

- (UIButton *)useImageButton
{
    if(_useImageButton == nil){
        _useImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_useImageButton setTitle:@"使用照片" forState:UIControlStateNormal];
        [_useImageButton.titleLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _useImageButton;
}

- (UIImageView *)imageView
{
    if(_imageView == nil){
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    
    return _imageView;
}

@end
