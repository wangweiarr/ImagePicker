//
//  IPImageReaderCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPImageReaderCell.h"
#import "IPZoomScrollView.h"

@interface IPZoomScrollView (private)

- (void)prepareForReuse;

@end

@interface IPImageReaderCell()

@property (nonatomic, strong)IPZoomScrollView *zoomScroll;

@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation IPImageReaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // Configure the cell
        self.backgroundColor = [UIColor blackColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _zoomScroll  = [[IPZoomScrollView alloc]init];
        _zoomScroll.frame = self.bounds;
        [self.contentView addSubview:_zoomScroll];
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"PlayButtonOverlayLarge"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"PlayButtonOverlayLargeTap"] forState:UIControlStateHighlighted];
        _playBtn.hidden = YES;
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playBtn];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_zoomScroll prepareForReuse];
    
    _playBtn.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _zoomScroll.frame = self.bounds;
    
    _playBtn.frame = CGRectMake(0, 0, 44, 44);
    _playBtn.center = self.contentView.center;
}

- (void)setAssetModel:(id<IPAssetBrowserProtocol>)assetModel
{
    _assetModel = assetModel;
    
    if([self displayingVideo]) {
        self.playBtn.hidden = NO;
    }else {
        self.playBtn.hidden = YES;
    }
    
    self.zoomScroll.assetModel = assetModel;
}

- (void)playBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(cell:videoPlayBtnClick:)]) {
        [self.delegate cell:self videoPlayBtnClick:sender];
    }
}

- (BOOL)displayingVideo
{
    return [_assetModel respondsToSelector:@selector(isVideo)] && _assetModel.isVideo;
}

@end

