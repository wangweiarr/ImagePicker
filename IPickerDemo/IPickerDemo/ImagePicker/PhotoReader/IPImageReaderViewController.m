//
//  IPImageReaderViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"
#import "IPZoomScrollView.h"
#import "IPAssetModel.h"
#import "IPAlertView.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPPrivateDefine.h"
#import "IPAnimationTranstion.h"
#import "IPImageReaderCell.h"

@interface IPImageReaderViewController ()<UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

/**图片数组*/
@property (nonatomic, strong)NSArray *dataArr;

/**第一次出现时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isFirst;

/**发生转屏时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isRoration;

/**需要跳转到指定位置*/
@property (nonatomic, assign)NSUInteger defaultShowPage;

/**左返回按钮*/
@property (nonatomic, weak)UIButton *leftButton;

/**右返回按钮*/
@property (nonatomic, weak)UIButton *rightButton;

/**头部视图*/
@property (nonatomic, weak)UIImageView *headerView;

/**当前位置*/
@property (nonatomic, assign)NSUInteger currentPage;

/**旋屏前的位置*/
@property (nonatomic, assign)NSUInteger pageIndexBeforeRotation;


@end

@implementation IPImageReaderViewController

static NSString * const reuseIdentifier = @"IPImageReaderViewControllerCell";

#pragma mark - init

+ (instancetype)imageReaderViewControllerWithDatas:(NSArray<IPAssetModel *> *)assets
{
    if (assets == nil || assets.count == 0 ) {
        IPLog(@"initlize failure because of assets is nil");
        return nil;
    }
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:flow];
    vc.dataArr = assets;
    return vc;
}

+ (instancetype)imageReaderViewControllerWithDataSource:(id<IPImageReaderViewControllerDataSource>)dataSource
{
    if (!dataSource) {
        IPLog(@"initlize failure because of dataSource is nil");
        return nil;
    }
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:flow];
    
    return vc;
}


- (void)dealloc
{
    IPLog(@"IPImageReaderViewController---dealloc");
}

- (void)setUpDefaultShowPage:(NSUInteger)page
{
    NSUInteger totalPage;
    if (_dataArr.count > 0) {
        totalPage = _dataArr.count;
    } else if (_dataSource) {
        totalPage = [_dataSource numberOfAssetsOfImageReader:self];
    } else {
        totalPage = NSUIntegerMax;
    }
    
    if (page < totalPage) {
        _defaultShowPage = page;
    } else {
        IPLog(@"IPImageReaderViewController---setUpDefaultShowPage Error :%ld",page);
    }
}

#pragma mark - VC lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:[IPImageReaderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self addHeaderView];
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IOS7_STATUS_BAR_HEGHT + 44);
    self.leftButton.frame = CGRectMake(-5, IOS7_STATUS_BAR_HEGHT, 44, 44);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 44, IOS7_STATUS_BAR_HEGHT, 44, 44);
    
    NSUInteger maxIndex = self.dataArr.count - 1;
    NSUInteger minIndex = 0;
    if (self.defaultShowPage < minIndex) {
        self.defaultShowPage = minIndex;
    } else if (self.defaultShowPage > self.defaultShowPage) {
        self.defaultShowPage = maxIndex;
    }
    if (self.isFirst == NO) {
        
        if (self.defaultShowPage == 0) {//当滚动到0的位置时,默认是不调用scrolldidscroll方法的
            IPAssetModel *model = self.dataArr[0];
            self.rightButton.selected = model.isSelect;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.defaultShowPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        self.isFirst = YES;
    }
    if (self.isRoration) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isRoration = NO;
        IPAssetModel *model = self.dataArr[_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        [thePage displayImageWithFullScreenImage];
    }
    if (self.forceTouch) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        IPAssetModel *model = self.dataArr[_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        if (thePage) {
            self.forceTouch = NO;
            [thePage displayImageWithFullScreenImage];
        }
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.headerView.hidden = NO;
    IPAssetModel *model = self.dataArr[_defaultShowPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    self.navigationController.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
     IPLog(@"IPImageReaderViewController---didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}

- (void)addHeaderView
{
    //添加背景图
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.hidden = YES;
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

- (void)cancle
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)selectBtn:(UIButton *)btn
{
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
    IPAssetModel *model = self.dataArr[_currentPage];
    model.isSelect = btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnForReaderView:)]) {
        [self.delegate clickSelectBtnForReaderView:model];
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
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    // Perform layout
    _currentPage = _pageIndexBeforeRotation;
    self.isRoration = YES;
    
    IPAssetModel *model = self.dataArr[_currentPage];
    self.rightButton.selected = model.isSelect;
    
    [self.collectionView reloadData];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentPage;
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.isRoration = NO;
    IPAssetModel *model = self.dataArr[_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    
}
//#endif


#pragma mark - UICollectionViewDataSource Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    IPAssetModel *model = [self.dataArr objectAtIndex:indexPath.item];
    cell.zoomScroll.ipVc = self.ipVc;
    IPLog(@"cellForItemAtIndexPath--%tu",indexPath.item);
    cell.zoomScroll.imageModel = model;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRoration) {
        return;
    }
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.dataArr count] - 1) index = [self.dataArr count] - 1;
    NSUInteger previousCurrentPage = _currentPage;
    _currentPage = index;
    if (_currentPage != previousCurrentPage) {
        IPAssetModel *model = self.dataArr[_currentPage];
        self.rightButton.selected = model.isSelect;
    }
   
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 0.0f;
                     }completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 1.0f;
                     }completion:nil];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    IPAssetModel *model = self.dataArr[_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    
    NSLog(@"scrollViewDidEndDecelerating");
}


#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:NSClassFromString(@"IPickerViewController")]) {
        IPAnimationInverseTransition *inverseTransition = [[IPAnimationInverseTransition alloc]init];
        return inverseTransition;
    }else{
        return nil;
    }
}

- (IPZoomScrollView *)pageDisplayingPhoto:(IPAssetModel *)model
{
    IPZoomScrollView *thePage = nil;
    for (IPImageReaderCell *cell in self.collectionView.visibleCells) {
        if (cell.zoomScroll.imageModel == model) {
            thePage = cell.zoomScroll; break;
        }
    }
    return thePage;
}

@end

