//
//  IPImageReaderCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/1/17.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPZoomScrollView.h"

@interface IPImageReaderCell : UICollectionViewCell

/**伸缩图*/
@property (nonatomic, readonly)IPZoomScrollView *zoomScroll;

@end
