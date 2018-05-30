//
//  IPAblumCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlbumCell.h"
#import "IPAlbumModel.h"

@interface IPAlbumCell ()
/**封面view*/
@property (nonatomic, weak)UIImageView *posterView;
/**描述*/
@property (nonatomic, weak)UILabel *descLabel;
/**是否选中图片*/
@property (nonatomic, weak)UIImageView *accessoryImgView;


/**是否选中图片*/
@property (nonatomic, weak)UIView  *spliteline;
/**当前状态*/
//@property (nonatomic, assign)BOOL ;
@end

@implementation IPAlbumCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatSubViews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self creatSubViews];
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView  *spliteline = [[UIView alloc]init];
    spliteline.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.spliteline = spliteline;
    [self.contentView addSubview:spliteline];
    
    UIImageView *post = [[UIImageView alloc]init];
    post.clipsToBounds = YES;
    post.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:post];
    self.posterView = post;
    
    UILabel *descLabel = [[UILabel alloc]init];
    descLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:descLabel];
    self.descLabel = descLabel;
    
    UIImageView *selectedImgView = [[UIImageView alloc]init];
    selectedImgView.contentMode = UIViewContentModeCenter;
    selectedImgView.image = [UIImage imageNamed:@"forms_icon_select2"];
   
    [self.contentView addSubview:selectedImgView];
    self.accessoryImgView = selectedImgView;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    CGFloat margin = 10.0f;
    
    
    _posterView.frame = CGRectMake(margin/4, margin/4, viewH-margin/2, viewH-margin/2);
    _spliteline.frame = CGRectMake(CGRectGetMaxX(_posterView.frame), viewH-0.5, viewW, 0.5);
    
    _accessoryImgView.frame = CGRectMake(viewW - 2*margin - 20, 0, 20, viewH);
    _descLabel.frame = CGRectMake(CGRectGetMaxX(_posterView.frame) + margin, 0, viewW - CGRectGetWidth(_posterView.frame) - CGRectGetWidth(_accessoryImgView.frame) - margin, viewH);

    
}
- (void)setModel:(IPAlbumModel *)model{
    if (_model != model) {
        _model = model;
        self.posterView.image = model.posterImage;
        
        self.descLabel.text = [NSString stringWithFormat:@"%@ (%ld)",model.albumName, (long)model.imageCount];
        if (_model.isSelected) {
            self.descLabel.textColor = [UIColor colorWithRed:74/255.0 green:112/255.0 blue:210/255.0 alpha:1.0];
            
        }else {
            
            self.descLabel.textColor = [UIColor grayColor];
        }
        self.accessoryImgView.hidden = !_model.isSelected;
    }
    
}

@end
