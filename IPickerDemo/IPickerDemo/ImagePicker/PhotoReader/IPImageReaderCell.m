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
        [self addSubview:_zoomScroll];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_zoomScroll prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _zoomScroll.frame = self.bounds;
}

@end

