//
//  IPImageReaderLayout.m
//  IPickerDemo
//
//  Created by wangjianlong on 2018/5/31.
//  Copyright © 2018年 JL. All rights reserved.
//

#import "IPImageReaderLayout.h"
#import "IPPrivateDefine.h"

@implementation IPImageReaderLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGSize size = self.collectionView.bounds.size;
    self.itemSize = CGSizeMake(size.width, size.height);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.marginBetweenPages = 20;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttsArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
 
    IPLog(@"wjl == %s %@",__func__,NSStringFromCGRect(self.collectionView.bounds));
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0;
    __block CGFloat min = CGFLOAT_MAX;
    __block NSUInteger minIdx;
    //找到被复用的cell的index
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ABS(centerX - obj.center.x) < min) {
            min = ABS(centerX-obj.center.x);
            minIdx = idx;
        }
    }];
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (minIdx - 1 == idx) {
            obj.center = CGPointMake(obj.center.x-self.marginBetweenPages, obj.center.y);
        }
        if (minIdx + 1 == idx) {
            obj.center = CGPointMake(obj.center.x+self.marginBetweenPages, obj.center.y);
        }
    }];
    return layoutAttsArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
