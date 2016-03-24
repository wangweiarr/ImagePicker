//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPImageModel;

@interface IPZoomScrollView : UIScrollView

@property (nonatomic) IPImageModel * imageModel;

- (void)prepareForReuse;

- (void)displayImage;
- (void)displayImageWithFullScreenImage:(UIImage *)img;
@end
