//
//  IPImageReaderCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPImageReaderCell.h"
#import "UICollectionViewCell+PhotoReader.h"

@implementation IPImageReaderCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        // Configure the cell
        self.backgroundColor = [UIColor clearColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _zoomScroll  = [[IPZoomScrollView alloc]init];
        _zoomScroll.frame = self.bounds;
        [self.contentView addSubview:_zoomScroll];
        if (@available(iOS 11.0, *)) {
            _zoomScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return self;
}
- (void)prepareForReuse{
    [super prepareForReuse];
    [self.zoomScroll prepareForReuse];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _zoomScroll.frame = self.bounds;
}

- (UIImageView *)animateImageView
{
    return _zoomScroll.animateImageView;
}

- (UIImageView *)sourceImageView
{
    return _zoomScroll.photoImageView;
}

@end

