//
//  IPImageReaderCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPAssetBrowserProtocol.h"

@class IPZoomScrollView,IPImageReaderCell;

@protocol IPImageReaderCellDelegate <NSObject>

- (void)cell:(IPImageReaderCell *)cell videoPlayBtnClick:(UIButton *)btn;

@end

@interface IPImageReaderCell : UICollectionViewCell

@property (nonatomic, readonly) IPZoomScrollView *zoomScroll;
@property (nonatomic, strong) id<IPAssetBrowserProtocol> assetModel;
@property (nonatomic,weak) id<IPImageReaderCellDelegate> delegate;

@end
