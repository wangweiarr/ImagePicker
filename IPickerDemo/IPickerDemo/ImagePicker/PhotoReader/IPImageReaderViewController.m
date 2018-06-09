//
//  IPImageReaderViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"
#import "IPAssetModel.h"
#import "IPAlertView.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPPrivateDefine.h"
#import "IPAnimationTranstion.h"
#import "IPImageReaderCell.h"
#import "IPImageReaderLayout.h"

@interface IPImageReaderViewController ()<UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

/**图片数组*/
@property (nonatomic, strong)NSArray *dataArr;

/**发生转屏时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isRoration;

/**需要跳转到指定位置*/
@property (nonatomic, assign)NSUInteger currentPage;

/**左返回按钮*/
@property (nonatomic, weak)UIButton *leftButton;

/**右返回按钮*/
@property (nonatomic, weak)UIButton *rightButton;

/**头部视图*/
@property (nonatomic, weak)UIImageView *headerView;

/**旋屏前的位置*/
@property (nonatomic, assign)NSUInteger pageIndexBeforeRotation;

@end

@implementation IPImageReaderViewController

static NSString * const reuseIdentifier = @"IPImageReaderViewCell";

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[IPImageReaderLayout new]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.hidden = YES;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[IPImageReaderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    _animationTranstionBgColor = [UIColor blackColor];
    self.view.backgroundColor = _animationTranstionBgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addHeaderView];
    
}

- (void)addHeaderView{
    
    //添加背景图
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.userInteractionEnabled = YES;
    UIImage *headerImage =[UIImage imageNamed:@"photobrowse_top"];
    headerView.image = headerImage;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *leftBtnImage =[UIImage imageNamed:@"bar_btn_icon_returntext_white"];
    [leftBtn setImage:leftBtnImage forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:leftBtn];
    self.leftButton = leftBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *image =[UIImage imageNamed:@"img_icon_check_Big"];
    UIImage *image_p =[UIImage imageNamed:@"img_icon_check_Big_p"];
    [rightBtn setImage:image forState:UIControlStateNormal];
    [rightBtn setImage:image_p forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:rightBtn];
    self.rightButton = rightBtn;
    
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    IPLog(@"wjl == %s",__func__);
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IOS7_STATUS_BAR_HEGHT + 44);
    self.leftButton.frame = CGRectMake(-5, IOS7_STATUS_BAR_HEGHT, 44, 44);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 44, IOS7_STATUS_BAR_HEGHT, 44, 44);
    
    NSUInteger maxIndex = self.dataArr.count - 1;
    NSUInteger minIndex = 0;
    if (self.currentPage < minIndex) {
        self.currentPage = minIndex;
    } else if (self.currentPage > maxIndex) {
        self.currentPage = maxIndex;
    }
    
//    if (self.isRoration) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//        self.isRoration = NO;
//        IPImageReaderCell *cell = self.collectionView.visibleCells.firstObject;
//        [cell displayImageWithFullScreenImage];
//    }
    if (self.forceTouch) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        IPImageReaderCell *cell = self.collectionView.visibleCells.firstObject;
        if (cell) {
            self.forceTouch = NO;
            [cell displayImageWithFullScreenImage];
        }
        
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView setContentOffset:CGPointMake(self.view.bounds.size.width * _currentPage, self.collectionView.contentOffset.y)];
    self.collectionView.hidden = NO;
    IPImageReaderCell *cell = self.collectionView.visibleCells.firstObject;
    [cell displayImageWithFullScreenImage];
    
    if ([self.dataSource respondsToSelector:@selector(imageReader:currentAssetIsSelect:)]) {
        self.rightButton.selected = [self.dataSource imageReader:self currentAssetIsSelected:_currentPage];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
     IPLog(@"IPImageReaderViewController---didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    
    IPLog(@"IPImageReaderViewController---dealloc");
}
- (void)cancle{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)selectBtn:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        if (self.currentSelectCount == self.maxSelectCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxSelectCount];
            btn.selected = NO;
            return;
        }
        self.currentSelectCount ++;
    }else {
        self.currentSelectCount --;
    }
    if ([self.delegate respondsToSelector:@selector(imageReader:currentAssetIsSelect:)]) {
        [self.delegate imageReader:self currentAssetIsSelect:btn.selected];
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfAssetsInImageReader:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.readerVc = self;
    IPLog(@"cellForItemAtIndexPath--%tu",indexPath.item);
    IPImageSourceType type = [self.dataSource imageReader:self soureTypeWithIndex:indexPath.item];
    if (type == IPImageSourceTypeAlbum) {
        id asset = [self.dataSource imageReader:self albumAssetWithIndex:indexPath.item];
        [cell displayImageWithAlbumAsset:asset];
    } else if (type == IPImageSourceTypeNet) {
        [cell displayImageWithImageUrl:[self.dataSource imageReader:self simpleQualityAssetUrlWithIndex:indexPath.item]];
    } else {
        [cell displayImageWithImage:[self.dataSource imageReader:self simpleQualityAssetImgWithIndex:indexPath.item]];
    }
    
    

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return self.view.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageReaderCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPLog(@"didEndDisplayingCell--%tu",indexPath.item);
//    [cell.zoomScroll prepareForReuse];
    
}

#pragma mark <UICollectionViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    IPLog(@"wjl == %s",__func__);
    if (self.isRoration) {
        return;
    }
    
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.dataSource numberOfAssetsInImageReader:self] - 1) index = [self.dataSource numberOfAssetsInImageReader:self] - 1;
    NSUInteger previousCurrentPage = _currentPage;
    _currentPage = index;
    if (_currentPage != previousCurrentPage) {
        if ([self.dataSource respondsToSelector:@selector(imageReader:currentAssetIsSelect:)]) {
            self.rightButton.selected = [self.dataSource imageReader:self currentAssetIsSelected:_currentPage];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 0.0f;
                     }completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 1.0f;
                     }completion:nil];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    IPImageReaderCell *cell = self.collectionView.visibleCells.firstObject;
    [cell displayImageWithFullScreenImage];
}

#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:NSClassFromString(@"IPickerViewController")]) {
        IPAnimationInverseTransition *inverseTransition = [[IPAnimationInverseTransition alloc]init];
        return inverseTransition;
    }else{
        return nil;
    }
}

#pragma mark - statusBar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - rorate

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
//    // Perform layout
//    _currentPage = _pageIndexBeforeRotation;
//    self.isRoration = YES;
//
//    IPAssetModel *model = self.dataArr[_currentPage];
//    self.rightButton.selected = model.isSelect;
//
//    [self.collectionView reloadData];
//}
//#else
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    
    IPLog(@"wjl == %s",__func__);
    // Perform layout
    _currentPage = _pageIndexBeforeRotation;

//    IPAssetModel *model = self.dataArr[_currentPage];
    self.rightButton.selected = [self.dataSource imageReader:self currentAssetIsSelected:_currentPage];
    
    [self.collectionView setContentOffset:CGPointMake(_currentPage*CGRectGetWidth(self.collectionView.frame), self.collectionView.contentOffset.y) animated:NO];
//    [self.collectionView reloadData];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    IPLog(@"wjl == %s",__func__);
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentPage;
    self.isRoration = YES;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.isRoration = NO;
//    IPImageReaderCell *cell = self.collectionView.visibleCells.firstObject;
//    [cell displayImageWithFullScreenImage];
    
    IPLog(@"wjl == %s",__func__);
}
//#endif


#pragma mark - interface
- (void)setUpCurrentSelectPage:(NSUInteger)page
{
    if (page >= [self.dataSource numberOfAssetsInImageReader:self]) {
        page = [self.dataSource numberOfAssetsInImageReader:self] - 1;
    }
    _currentPage = page;
}

@end

