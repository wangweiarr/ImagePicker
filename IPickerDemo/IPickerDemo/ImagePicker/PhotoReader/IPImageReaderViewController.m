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
#import "IPImageReaderCellLayout.h"
#import "IPVideoPlayerViewController.h"

@interface IPImageReaderViewController ()<
    UICollectionViewDelegateFlowLayout,
    UINavigationControllerDelegate,
    IPImageReaderCellDelegate
>

/*asset数组*/
@property (nonatomic, strong)NSMutableArray *assets;

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
    
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:[IPImageReaderCellLayout new]];
    vc.assets = [NSMutableArray arrayWithArray:assets];
    return vc;
}

+ (instancetype)imageReaderViewControllerWithDataSource:(id<IPImageReaderViewControllerDataSource>)dataSource
{
    if (!dataSource) {
        IPLog(@"initlize failure because of dataSource is nil");
        return nil;
    }
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:[IPImageReaderCellLayout new]];
    
    return vc;
}


- (void)dealloc
{
    IPLog(@"IPImageReaderViewController---dealloc");
}

- (void)setUpDefaultShowPage:(NSUInteger)page
{
    NSUInteger totalPage;
    if (_assets.count > 0) {
        totalPage = _assets.count;
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, STATUS_BAR_HEIGHT() + 44);
    self.leftButton.frame = CGRectMake(-5, STATUS_BAR_HEIGHT(), 44, 44);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 44, STATUS_BAR_HEIGHT(), 44, 44);
    
    NSUInteger maxIndex = self.assets.count - 1;
    NSUInteger minIndex = 0;
    if (self.defaultShowPage < minIndex) {
        self.defaultShowPage = minIndex;
    } else if (self.defaultShowPage > self.defaultShowPage) {
        self.defaultShowPage = maxIndex;
    }
    if (self.isFirst == NO) {
        
        if (self.defaultShowPage == 0) {//当滚动到0的位置时,默认是不调用scrolldidscroll方法的
            IPAssetModel *model = [self getAssetModelWithIndex:0];
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
        IPAssetModel *model = [self getAssetModelWithIndex:_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
            if (success && image) {
                [thePage displayImageWithFullScreenImage:image];
            }
        }];
        
    }
    if (self.forceTouch) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        IPAssetModel *model = [self getAssetModelWithIndex:_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        if (thePage) {
            self.forceTouch = NO;
            [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
                if (success && image) {
                    [thePage displayImageWithFullScreenImage:image];
                }
            }];
        }
        
    }
}

- (IPAssetModel *)getAssetModelWithIndex:(NSUInteger)index
{
    if (_assets.count > 0 && _assets.count > index) {
        return self.assets[index];
    } else if ([_dataSource imageReader:self assetModelWithIndex:index]) {
        return [_dataSource imageReader:self assetModelWithIndex:index];
    } else {
        return nil;
    }
}

- (NSUInteger)getCountOfAssetModel
{
    if (_assets) {
        return _assets.count;
    } else if (_dataSource) {
        return [_dataSource numberOfAssetsOfImageReader:self];
    } else {
        return 0;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.headerView.hidden = NO;
    IPAssetModel *model = [self getAssetModelWithIndex:_defaultShowPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    
    [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
        if (success && image) {
            [thePage displayImageWithFullScreenImage:image];
        }
    }];
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
    IPAssetModel *model = [self getAssetModelWithIndex:_currentPage];
    model.isSelect = btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnForReaderView:)]) {
        [self.delegate clickSelectBtnForReaderView:model];
    }
    
}

#pragma mark - IPImageReaderCellDelegate

- (void)cell:(IPImageReaderCell *)cell videoPlayBtnClick:(UIButton *)btn
{
    id <IPAssetBrowserProtocol>model = cell.assetModel;
    [[IPAssetManager defaultAssetManager] getVideoWithAsset:model Completion:^(AVPlayerItem *item, NSDictionary *info) {
        IPVideoPlayerViewController *videoPlayer = [[IPVideoPlayerViewController alloc]initWithPlayerItem:item];
        [self presentViewController:videoPlayer animated:YES completion:nil];
    }];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _currentPage = _pageIndexBeforeRotation;
    self.isRoration = YES;
    
    IPAssetModel *model = [self getAssetModelWithIndex:_currentPage];
    self.rightButton.selected = model.isSelect;
    
    [self.collectionView reloadData];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.isRoration = NO;
        IPAssetModel *model = [self getAssetModelWithIndex:self.currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
            if (success && image) {
                [thePage displayImageWithFullScreenImage:image];
            }
        }];
    }];
}


#pragma mark - UICollectionViewDataSource Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getCountOfAssetModel];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    IPAssetModel *model = [self getAssetModelWithIndex:indexPath.item];

    IPLog(@"wjl cellForItemAtIndexPath--%tu",indexPath.item);
    cell.assetModel = model;
    cell.delegate = self;
    cell.zoomScroll.index = indexPath.item;
    [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
        if ([cell.zoomScroll.assetModel isEqual:model]) {
            if (image && success) {
                [cell.zoomScroll displayImageWithImage:image];
            } else {
                [cell.zoomScroll displayImageWithError];
            }
        }
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.bounds.size;
}

- (void)loadAdjacentPhotosIfNecessary:(id<IPAssetBrowserProtocol>)photo {
    IPZoomScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPage == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <IPAssetBrowserProtocol> photo = [self getAssetModelWithIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
                       
                    }];
                    IPLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self getCountOfAssetModel] - 1) {
                // Preload index + 1
                id <IPAssetBrowserProtocol> photo = [self getAssetModelWithIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
                        
                    }];
                    IPLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRoration) {
        return;
    }
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.assets count] - 1) index = [self.assets count] - 1;
    NSUInteger previousCurrentPage = _currentPage;
    _currentPage = index;
    if (_currentPage != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
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
    IPAssetModel *model = [self getAssetModelWithIndex:_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [model loadUnderlyingImageAndComplete:^(BOOL success, UIImage *image) {
        if (success && image) {
            [thePage displayImageWithFullScreenImage:image];
        }
    }];
    
    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index
{
    // Handle 0 photos
    if (![self getCountOfAssetModel]) {
        // Show controls
//        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Release images further away than +/-1
    // TODO
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    IPAssetModel *currentPhoto = [self getAssetModelWithIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    self.rightButton.selected = currentPhoto.isSelect;
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
        if ([cell.zoomScroll.assetModel isEqual:model]) {
            thePage = cell.zoomScroll; break;
        }
    }
    return thePage;
}

@end

