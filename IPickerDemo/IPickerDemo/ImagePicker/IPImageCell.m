//
//  IPImageCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageCell.h"
#import "IPImageModel.h"
#import "IPAssetManager.h"
//#import "AHUIImageNameHandle.h"

@interface IPImageCell ()
/**缩略图*/
@property (nonatomic, weak) UIImageView *imgView;
/**右上角按钮*/
@property (nonatomic, weak) UIButton *rightCornerBtn;

@end

@implementation IPImageCell
- (void)prepareForReuse{
    self.imgView.image = nil;
}
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
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [self.contentView addSubview:imgView];
    imgView.image = [UIImage imageNamed:@"default_8_120"];
    self.imgView = imgView;
    
    UIButton *rightCornerBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 18-5, 5, 18, 18)];
   
    [rightCornerBtn addTarget:self action:@selector(clickBtnInCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rightCornerBtn];
    self.rightCornerBtn = rightCornerBtn;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image,*image_p;
    if ([UIScreen mainScreen].bounds.size.width<375) {
        
        image =[UIImage imageNamed:@"album_icon_check"];
        image_p =[UIImage imageNamed:@"album_icon_check_p"];
    }else {
        image =[UIImage imageNamed:@"img_icon_check_Big"];
        image_p =[UIImage imageNamed:@"img_icon_check_Big_p"];
    }
    [self.rightCornerBtn setImage:image forState:UIControlStateNormal];
    [self.rightCornerBtn setImage:image_p forState:UIControlStateSelected];
    
    self.imgView.frame = self.bounds;
    CGFloat w = self.bounds.size.width / 2.6f;
    self.rightCornerBtn.frame = CGRectMake(self.bounds.size.width - w, 0, w, w);
}
- (void)setModel:(IPImageModel *)model{
    _model = model;
    
    __weak typeof(self) weakSelf = self;
    self.rightCornerBtn.selected = model.isSelect;
    [[IPAssetManager defaultAssetManager]getThumibImageWithAsset:_model photoWidth:_model.imageSize completion:^(UIImage *photo, NSDictionary *info) {
        weakSelf.imgView.image = photo;
    }];
    
}
- (void)clickBtnInCell:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    self.model.isSelect = btn.selected;
    
    BOOL denySelect;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRightCornerBtnForView:)]) {
        denySelect = [self.delegate clickRightCornerBtnForView:self.model];
    }
    if (!denySelect) {
        btn.selected = NO;
        self.model.isSelect = NO;
    }
    
    
}
@end
