//
//  IPImageCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPImageModel;
@protocol IPImageCellDelegate<NSObject>

- (void)clickRightCornerBtnForView:(IPImageModel *)assetModel;

@end
@interface IPImageCell : UICollectionViewCell


/**代理*/
@property (nonatomic, weak)id <IPImageCellDelegate> delegate;
/**数据模型*/
@property (nonatomic, strong)IPImageModel *model;
@end
