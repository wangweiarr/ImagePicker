//
//  IPAlbumModel.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPAlbumModel : NSObject
/**封面图片*/
@property (nonatomic, strong)UIImage *posterImage;

/**图片数量*/
@property (nonatomic, assign)NSUInteger  imageCount;

/**相册名称*/
@property (nonatomic, copy)NSString *albumName;

/**存放所有图片的数组*/
@property (nonatomic, strong)NSURL *groupURL;


@end
