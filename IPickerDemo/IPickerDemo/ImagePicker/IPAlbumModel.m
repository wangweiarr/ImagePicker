//
//  IPAlbumModel.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlbumModel.h"

@implementation IPAlbumModel
-(NSComparisonResult)compareImageCount:(IPAlbumModel *)albumModel
{
    
    //默认按图片数量排序
    
    NSComparisonResult result = [[NSNumber numberWithUnsignedInteger:albumModel.imageCount] compare:[NSNumber numberWithUnsignedInteger:self.imageCount]];//注意:基本数据类型要进行数据转换
    
    
    if (result == NSOrderedSame)
    {
        result = [self.albumName compare:albumModel.albumName];
        
    }
    
    return result;
    
}
@end
