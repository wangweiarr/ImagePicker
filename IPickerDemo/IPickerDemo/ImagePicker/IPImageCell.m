//
//  IPImageCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageCell.h"
#import "IPImageModel.h"

@interface IPImageCell ()
/**缩略图*/
@property (nonatomic, weak) UIImageView *imgView;
/**右上角按钮*/
@property (nonatomic, weak) UIButton *rightCornerBtn;

@end

@implementation IPImageCell
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
- (void)creatSubViews{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self.contentView addSubview:imgView];
    imgView.image = self.model.thumbnail;
    self.imgView = imgView;
    
    UIButton *rightCornerBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 18-5, 5, 18, 18)];
    [rightCornerBtn setImage:[UIImage imageNamed:@"album_icon_check"] forState:UIControlStateNormal];
    [rightCornerBtn setImage:[UIImage imageNamed:@"album_icon_check_p"] forState:UIControlStateSelected];
    [rightCornerBtn addTarget:self action:@selector(clickBtnInCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rightCornerBtn];
    self.rightCornerBtn = rightCornerBtn;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgView.frame = self.bounds;
    self.rightCornerBtn.frame = CGRectMake(self.bounds.size.width - 30, 0, 30, 30);
}
- (void)setModel:(IPImageModel *)model{
    _model = model;
    self.imgView.image = model.thumbnail;
    self.rightCornerBtn.selected = model.isSelect;
}
- (void)clickBtnInCell:(UIButton *)btn{
    btn.selected = !btn.selected;
    self.model.isSelect = btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRightCornerBtnForView:)]) {
        [self.delegate clickRightCornerBtnForView:self.model.url];
    }
}
@end
