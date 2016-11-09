//
//  IP3DTouchPreviewVC.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/4/23.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPAssetModel;
@interface IP3DTouchPreviewVC : UIViewController
/**size*/
//@property (nonatomic, assign)CGSize imgSize;

/**容器*/
@property (nonatomic, weak)UIImageView *imgView;

+ (instancetype)previewViewControllerWithModel:(IPAssetModel *)model;
@end
