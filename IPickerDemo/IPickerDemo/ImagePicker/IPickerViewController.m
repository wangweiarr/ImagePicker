//
//  IPickerViewController.m
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPickerViewController.h"
#import "IP3DTouchPreviewVC.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPAssetManager.h"
#import "IPImageReaderViewController.h"
#import "IPAlertView.h"
#import "IPTakeVideoViewController.h"
#import "IPAnimationTranstion.h"
#import "IPPrivateDefine.h"
#import "IPTakePhotoViewController.h"
#import "IPMediaCenter.h"
#import "IPVideoPlayerViewController.h"
#import "IPPresentAnimationTranstion.h"


NSString * const IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION = @"IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION";

@interface IPickerViewController ()<
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    IPAlbumViewDelegate,
    IPAssetManagerDelegate,
    IPImageCellDelegate,
    IPImageReaderViewControllerDelegate,
    IPImageReaderViewControllerDatasource,
    IPTakeVideoViewControllerDelegate,
    UIViewControllerPreviewingDelegate,
    CAAnimationDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    IPTakePhotoViewControllerDelegate,
    UIViewControllerTransitioningDelegate
>


/**头部视图*/
@property (nonatomic, weak)UIView *headerView;

/**头部视图*/
@property (nonatomic, weak)UIButton *leftBtn;

/**中部视图*/
@property (nonatomic, weak)UIButton *centerBtn;

/**箭头指示器*/
@property (nonatomic, weak)UIImageView *arrowImge;

/**右部LABEL*/
@property (nonatomic, weak)UILabel *rightLabel;

/**右部视图*/
@property (nonatomic, weak)UIButton *rightBtn;

/**头部视图底部分割线*/
@property (nonatomic, weak)UIView *spliteView;

/**主视图*/
@property (nonatomic, weak)UICollectionView *mainView;

/**布局对象*/
@property (nonatomic, strong)UICollectionViewFlowLayout *flowOut;

/**相册列表view*/
@property (nonatomic, strong)IPAlbumView *albumView;

/**选中的图片数量*/
@property (nonatomic, assign)NSUInteger selectPhotoCount;

/**当前选择的图片数组*/
@property (nonatomic, strong)NSMutableArray *priCurrentSelArr;

/**专辑背景view*/
@property (nonatomic, strong)UIView *albumBackView;

/**图片数组的缓存*/
@property (nonatomic, strong)NSMutableDictionary *imageModelDic;

/**当前显示的图片数组*/
@property (nonatomic, strong)NSMutableArray *curImageModelArr;

/**显示样式*/
@property (nonatomic, assign)IPickerViewControllerDisplayStyle displayStyle;

/**需要重新刷新*/
@property (nonatomic, assign)BOOL refreshData;

/**拍照*/
@property (nonatomic, strong)UIImagePickerController *imagePicker;

@property(nonatomic,assign)CGRect finalCellRect;

@property (nonatomic, assign)NSUInteger selectIndex;

@end


static NSString *IPicker_CollectionID = @"IPicker_CollectionID";

@implementation IPickerViewController


#pragma mark interface
+ (instancetype)instanceWithDisplayStyle:(IPickerViewControllerDisplayStyle)style
{
    IPickerViewController *ipVC = [[IPickerViewController alloc]init];
    
    ipVC.displayStyle = style;
    return ipVC;
}

- (void)exitIPickerWithAnimation:(BOOL)animation
{
    if (animation) {
        [self exitIPicker];
    }
}

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.maxCount = 50;
        
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        self.maxCount = 50;
        
    }
    return self;
}

- (void)getDataFromManager
{
    
    [self.defaultAssetManager requestUserpermission];
}

- (void)dealloc
{
    IPLog(@"IPickerViewController--dealloc");
    [IPMediaCenter realeaseCenter];
    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.navigationController.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self addMainView];
    [self addHeaderView];
    [self getDataFromManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat headerH = IOS7_STATUS_BAR_HEGHT + headerHeight;
    CGFloat btnH = headerHeight;
    CGFloat btnW = headerHeight;
    CGFloat MaxMargin = 5.0f;
    
    
    self.headerView.frame = CGRectMake(0, 0, viewW, headerH);
    self.leftBtn.frame = CGRectMake(MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    CGSize tempSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]/*,NSParagraphStyleAttributeName:paragraph*/};
    tempSize = [@"这里是汽车之家测试" boundingRectWithSize:CGSizeMake(MAXFLOAT, btnH) options: NSStringDrawingTruncatesLastVisibleLine |
                    NSStringDrawingUsesLineFragmentOrigin |
                    NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    CGSize size = [self.centerBtn sizeThatFits:tempSize];
    CGFloat minMargin = 0;
    if (size.width > tempSize.width) {
        size = tempSize;
        minMargin = 6;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            minMargin = 3;
        }
    }
    self.centerBtn.frame = CGRectMake(self.headerView.center.x - size.width/2, IOS7_STATUS_BAR_HEGHT, size.width, btnH);
    self.rightBtn.frame = CGRectMake(viewW - btnW -MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    CGFloat labelW = 18.0f;
    if (_selectPhotoCount > 9) {
        
        self.rightLabel.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW-3, IOS7_STATUS_BAR_HEGHT+13, labelW+6, labelW);
    }else {
        
        [self.rightLabel setFrame:CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW, IOS7_STATUS_BAR_HEGHT+13, labelW, labelW)];
        
    }
    
    self.arrowImge.frame = CGRectMake(CGRectGetMaxX(self.centerBtn.frame)- minMargin, IOS7_STATUS_BAR_HEGHT, btnW/2, btnH);
    
    
    self.spliteView.frame = CGRectMake(0, headerH - 0.5,viewW, 0.5);
    
    self.mainView.frame = CGRectMake(0, headerH, viewW, viewH - headerH);
}

- (void)addHeaderView
{
    
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor clearColor];
    [leftBtn sizeToFit];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithRed:74/255.0 green:112/255.0 blue:210/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [leftBtn addTarget:self action:@selector(exitIPicker) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [centerBtn addTarget:self action:@selector(displayAlbumView:) forControlEvents:UIControlEventTouchUpInside];
    centerBtn.contentMode = UIViewContentModeCenter;
    centerBtn.titleLabel.font = [UIFont systemFontOfSize:15];//textsize04
    centerBtn.backgroundColor = [UIColor clearColor];
    [centerBtn setTitle:@"获取资源中..." forState:UIControlStateNormal];
    [centerBtn setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
    [centerBtn sizeToFit];
    [headerView addSubview:centerBtn];
    self.centerBtn = centerBtn;
    
    
    UIImageView *arrowImge = [[UIImageView alloc]init];
    arrowImge.contentMode = UIViewContentModeCenter;
    UIImage *image =[UIImage imageNamed:@"common_icon_arrow"];
    [arrowImge  setImage:image];
    [headerView addSubview:arrowImge];
    arrowImge.hidden = YES;
    self.arrowImge = arrowImge;
    
    UILabel    *rightLabel = [[UILabel alloc]init];
    rightLabel.font = [UIFont systemFontOfSize:12];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.clipsToBounds = YES;
    rightLabel.textColor = [UIColor whiteColor];
    [rightLabel setBackgroundColor:[UIColor colorWithRed:74/255.0 green:112/255.0 blue:210/255.0 alpha:1.0]];
    [rightLabel setText:@""];
    [rightLabel sizeToFit];
    rightLabel.hidden = YES;
    [headerView addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn sizeToFit];
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithRed:74/255.0 green:112/255.0 blue:210/255.0 alpha:1.0] forState:UIControlStateSelected];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn.userInteractionEnabled = NO;
    [headerView addSubview:rightBtn];
    rightBtn.backgroundColor = [UIColor clearColor];
    self.rightBtn = rightBtn;
    
    UIView *spliteView = [[UIView alloc]init];
    spliteView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [headerView addSubview:spliteView];
    self.spliteView = spliteView;
}

- (void)addMainView
{
    _flowOut = [[UICollectionViewFlowLayout alloc]init];
    _flowOut.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
    UICollectionView *mainView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowOut];
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView setBackgroundColor:[UIColor lightGrayColor]];
    mainView.delegate = self;
    mainView.dataSource = self;
    [mainView registerClass:[IPImageCell class] forCellWithReuseIdentifier:IPicker_CollectionID];
    self.mainView = mainView;
    [self.view addSubview:mainView];
}

#pragma mark - collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.curImageModelArr.count;
}

- (IPImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IPicker_CollectionID forIndexPath:indexPath];
    cell.ipVc = self;
    if (self.curImageModelArr.count > indexPath.item) {
        
        IPAssetModel *model = self.curImageModelArr[indexPath.item];
        cell.model = model;
        cell.delegate = self;
    }
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
        
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger rowCount = 4;
    NSUInteger margin = 5;
    CGFloat itemWidth = (collectionView.frame.size.width - (rowCount-1)*margin)/rowCount;
    return CGSizeMake(itemWidth, itemWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.curImageModelArr.count)
    {
        IPAssetModel *model = self.curImageModelArr[indexPath.item];
        
            
        __weak typeof(self) weakSelf = self;

        if(model.assetType == IPAssetModelMediaTypeVideo)
        {
            
            [[IPAssetManager defaultAssetManager] getVideoWithAsset:model Completion:^(AVPlayerItem *item, NSDictionary *info) {
                IPVideoPlayerViewController *videoPlayer = [[IPVideoPlayerViewController alloc]init];
                videoPlayer.playerItem = item;
                [weakSelf.navigationController pushViewController:videoPlayer animated:YES];
            }];
            
            
//            __block IPAlertView *alert = [IPAlertView showAlertViewAt:self.view Text:@"视频加载中..."];
//            [self.defaultAssetManager compressVideoWithAssetModel:model CompleteBlock:^(AVPlayerItem *item) {
//                [alert dismissFromHostView];
//                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
//
//                    [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:item Videourl:nil videoDuration:(float)model.duration thumbailImage:model.VideoThumbail];
//
//                }
//                NSLog(@"%@",[NSThread currentThread]);
//                
//            }];
            
        }
        else if (model.assetType == IPAssetModelMediaTypePhoto)
        {
            _selectIndex = indexPath.item;
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.curImageModelArr];
            NSUInteger targetIndex = indexPath.item;
            if (self.canTakePhoto) {
                [array removeObjectAtIndex:0];
                targetIndex = indexPath.item - 1;
            }
            IPImageReaderViewController *reader = [[IPImageReaderViewController alloc]init];
            reader.dataSource = self;
            reader.transitioningDelegate = self;
            reader.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [reader setUpCurrentSelectPage:targetIndex];
            reader.maxSelectCount = self.maxCount;
            reader.currentSelectCount = self.selectPhotoCount;
            reader.delegate = self;
//            [self.navigationController pushViewController:reader animated:YES];
            [self presentViewController:reader animated:YES completion:nil];
        }else
        {
            if (model.cellClickBlock)
            {
                model.cellClickBlock(model);
            }
        }
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell endDisplay];
}

#pragma  mark - 导航条左右按钮的处理逻辑

/**
 *  左上角的取消按钮点击
 */
- (void)exitIPicker
{
    
    CATransition * transition=[CATransition animation];
    transition.duration=0.3f;
    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type=kCATransitionReveal;
    if (self.popStyle == IPickerViewControllerPopStylePush) {
        transition.subtype=kCATransitionFromLeft;
    }else {
        transition.subtype = kCATransitionFromBottom;
    }
    
    transition.delegate=self;
    if (self.navigationController) {
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(self.presentingViewController){
        
        [self.view.layer addAnimation:transition forKey:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  右上角 完成 按钮点击
 */
- (void)completeBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCompleteBtn:)]) {
        [self.delegate didClickCompleteBtn:[self.priCurrentSelArr copy]];
    }
    [self exitIPicker];
}

#pragma mark 点击右上角的"对勾"对应的逻辑
/**
 *  点击cell右上角的选中按钮
 */
- (BOOL)clickRightCornerBtnForView:(IPAssetModel *)model
{
    if (model.isSelect) {
        if (self.selectPhotoCount >= self.maxCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxCount];
            return NO;
        }
        [self addImageModel:model WithIsAdd:YES];
    }else {
        [self addImageModel:model WithIsAdd:NO];
    }
    return YES;
}

/**
 *  点击大图浏览时的选中按钮的代理回调方法
 *
 *  @param assetModel 对应的imageModel对象
 */



- (void)addImageModel:(IPAssetModel *)model WithIsAdd:(BOOL)isAdd
{
    if (isAdd) {
        self.selectPhotoCount++;
        if (![self.priCurrentSelArr containsObject:model]) {
            [self.priCurrentSelArr addObject:model];
        }
    }else {
        self.selectPhotoCount--;
        if ([self.priCurrentSelArr containsObject:model]) {
            [self.priCurrentSelArr removeObject:model];
        }
        
    }
}

- (void)setSelectPhotoCount:(NSUInteger)selectPhotoCount
{
    if (_selectPhotoCount != selectPhotoCount) {
        
        _selectPhotoCount = selectPhotoCount;
        if (_selectPhotoCount == NSUIntegerMax) _selectPhotoCount = 0;
        if (_selectPhotoCount <= 0) {
            self.rightLabel.hidden = YES;
            self.rightBtn.userInteractionEnabled = NO;
            self.rightBtn.selected = NO;
        }else {
            self.rightBtn.userInteractionEnabled = YES;
            self.rightLabel.hidden = NO;
            self.rightBtn.selected = YES;
        }
        CGFloat labelW = 18.0f;
        if (_selectPhotoCount > 9) {
            
            self.rightLabel.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW-3, IOS7_STATUS_BAR_HEGHT+13, labelW+6, labelW);
        }else {
            
            [self.rightLabel setFrame:CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW, IOS7_STATUS_BAR_HEGHT+13, labelW, labelW)];
            
        }
        self.rightLabel.layer.cornerRadius = labelW/2;
        
        [self.rightLabel setText:[NSString stringWithFormat:@"%tu",_selectPhotoCount]];
    }
}

#pragma mark 点击中心按钮对应的逻辑
/**
 *  点击中部相册名称,展示相册列表
 */
- (void)displayAlbumView:(UIButton *)btn
{
    
    [self.centerBtn setTitle:@"选择相册" forState:UIControlStateNormal];
    if (_albumView == nil) {
        _albumView = [IPAlbumView albumViewWithData:self.defaultAssetManager.albumArr];
        _albumView.delegate =self;
        
       
    }
    if (_albumBackView == nil) {
        _albumBackView = [[UIView alloc]initWithFrame:CGRectMake(0, IOS7_STATUS_BAR_HEGHT + headerHeight, self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight)];
        _albumBackView.backgroundColor = [UIColor blackColor];
        _albumBackView.alpha = 0.0f;
    }
    
    if (_albumView.superview) {
        [self shouldRemoveFrom:nil];
        return;
    }
    
    [self.view insertSubview:_albumBackView belowSubview:self.headerView];
    [_albumView setFrame:CGRectMake(0,-(self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight) , self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight)];
    [self.view insertSubview:_albumView atIndex:2];
    [UIView animateWithDuration:0.1 animations:^{
        _albumBackView.alpha = 0.6f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.arrowImge.transform = CGAffineTransformRotate(self.arrowImge.transform,M_PI);
            
            _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
        }];
    }];
}

/**
 *  将专辑列表移除
 */
- (void)shouldRemoveFrom:(IPAlbumView *)albumView
{
    
    [self.centerBtn setTitle:self.defaultAssetManager.currentAlbumModel.albumName forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.arrowImge.transform = CGAffineTransformIdentity;
        _albumView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
        [_albumView removeFromSuperview];
        [_albumView setFrame:CGRectZero];
        _albumView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.1 animations:^{
            _albumBackView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (_albumBackView.superview) {
                [_albumBackView removeFromSuperview];
            }
        }];
    }];
    
}

/**
 *  选中专辑列表的某个cell时的回调方法
 *
 *  @param indexPath 点击对应的索引
 *  @param View      专辑列表 view
 */
- (void)clickCellForIndex:(NSIndexPath *)indexPath ForView:(IPAlbumView *)View
{
    IPAlbumModel *model = [self.defaultAssetManager.albumArr objectAtIndex:indexPath.item];
    if (model == self.defaultAssetManager.currentAlbumModel) {
        [self shouldRemoveFrom:View];
        return;
    }
    [self.centerBtn setTitle:model.albumName forState:UIControlStateNormal];
    self.defaultAssetManager.currentAlbumModel = model;
    [self shouldRemoveFrom:View];
    self.selectPhotoCount = self.priCurrentSelArr.count;
    
    if ([self.imageModelDic objectForKey:model.albumIdentifier]) {
        self.curImageModelArr = [self.imageModelDic objectForKey:model.albumIdentifier];

        [self.mainView reloadData];
    }else {
        [self.defaultAssetManager getImagesForAlbumModel:model];
    }
    
}
#pragma mark - Rotation
//- (BOOL)shouldAutorotate{
//    return NO;
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.mainView reloadData];
}


#pragma mark -IPAssetManager Delegate
- (void)loadImageUserDeny:(IPAssetManager *)manager
{
    NSString *message = @"请在设置->通用->访问限制->照片 启用访问图片的权限!";
    if ([[[UIDevice currentDevice]systemVersion]floatValue]<6.0) {
        message = @"请在设置->通用->访问限制->位置 启用定位服务!";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"图片访问失败" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
    [alertView show];
    
    [self.centerBtn setTitle:@"访问相册失败" forState:UIControlStateNormal];
    [self.centerBtn sizeToFit];
    [self.view setNeedsLayout];
}

- (void)loadImageOccurError:(IPAssetManager *)manager
{
    NSString *message = @"访问相册失败,请重试";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"图片访问失败" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
    [self.centerBtn setTitle:@"访问相册失败" forState:UIControlStateNormal];
    [self.centerBtn sizeToFit];
    [self.view setNeedsLayout];
}

- (void)loadImageDataFinish:(IPAssetManager *)manager
{
    
    self.curImageModelArr = [NSMutableArray arrayWithArray:self.defaultAssetManager.currentPhotosArr];
    if (self.defaultAssetManager.currentAlbumModel.albumIdentifier) {
        [self.imageModelDic setObject:self.curImageModelArr forKey:self.defaultAssetManager.currentAlbumModel.albumIdentifier];
    }
    if (self.displayStyle == IPickerViewControllerDisplayStyleImage) {
        if (_canTakePhoto) {
            [self.curImageModelArr insertObject:[self setUpTakePhotoData] atIndex:0];
        }
        [self.centerBtn setTitle:self.defaultAssetManager.currentAlbumModel.albumName forState:UIControlStateNormal];
        self.arrowImge.hidden = NO;
        [self.centerBtn sizeToFit];
        [self.view setNeedsLayout];
        [self.mainView reloadData];
    }else {
        if (_canTakeVideo) {
            [self.curImageModelArr insertObject:[self setUpTakeVideoData] atIndex:0];
        }
        self.centerBtn.userInteractionEnabled = NO;
        [self.centerBtn setTitle:@"选择视频" forState:UIControlStateNormal];
        self.rightBtn.hidden = YES;
        [self.centerBtn sizeToFit];
        [self.view setNeedsLayout];
        [self.mainView reloadData];
    }
}

#pragma mark - alert框的处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self exitIPicker];
}

#pragma mark -private
- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion
{
    [self.defaultAssetManager getAspectPhotoWithAsset:imageModel photoWidth:photoSize completion:completion];
}

- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion
{
    [self.defaultAssetManager getFullScreenImageWithAsset:imageModel photoWidth:photoSize completion:completion];
}

- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion
{
    [self.defaultAssetManager getThumibImageWithAsset:imageModel photoWidth:photoSize completion:completion];
}

- (void)getHighQualityImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion
{
    [self.defaultAssetManager getHighQualityImageWithAsset:imageModel photoWidth:photoSize completion:completion];
}

#pragma mark - lazy -
- (IPAssetManager *)defaultAssetManager{
    IPAssetManager *defaultAssetManager = [IPAssetManager defaultAssetManager];
    defaultAssetManager.dataType = (IPAssetManagerDataType)self.displayStyle;
    defaultAssetManager.delegate = self;
    return defaultAssetManager;
}

- (void)setMaxCount:(NSUInteger)maxCount{
    NSInteger tempCount = (NSInteger)maxCount;
    if (_maxCount != tempCount && tempCount > 0) {
        _maxCount = tempCount;
    }else {
        _maxCount = 50;
    }
}
- (NSMutableArray *)priCurrentSelArr{
    if (_priCurrentSelArr == nil) {
        _priCurrentSelArr = [NSMutableArray arrayWithCapacity:self.maxCount];
    }
    return _priCurrentSelArr;
}
- (NSMutableDictionary *)imageModelDic{
    if (_imageModelDic == nil) {
        _imageModelDic = [NSMutableDictionary dictionaryWithCapacity:self.defaultAssetManager.albumArr.count];
    }
    return _imageModelDic;
}


#pragma mark - about video -
- (void)presentTakeVideoViewController:(IPAssetManager *)manager{
    IPTakeVideoViewController *takeVideo = [[IPTakeVideoViewController alloc]init];
    takeVideo.delegate = self;
    [self presentViewController:takeVideo animated:YES completion:nil];
}

- (void)VisionDidCaptureFinish:(IPMediaCenter *)vision withThumbnail:(NSURL *)thumbnail withVideoDuration:(float)duration{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnail]];
    
    __weak typeof(self) weakSelf = self;
    [vision exportVideo:^(BOOL success,NSURL *url){
        
        if (success) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
                [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:nil Videourl:url videoDuration:duration thumbailImage:image];
            }
        }
        else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
                [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:nil Videourl:nil videoDuration:duration thumbailImage:image];
            }
        }
        [weakSelf popViewControllerCustomAnimation];
        
        //        [weakSelf exitIPickerWithAnimation:YES];
        
    }withProgress:^(float progress){
        
    }];
    
}
- (void)popViewControllerCustomAnimation {
    if (self.navViewControllers != 0 && self.navViewControllers < self.navigationController.viewControllers.count) {
        UIViewController *ctrl = self.navigationController.viewControllers[self.navViewControllers];
        CATransition * transition=[CATransition animation];
        transition.duration=0.3f;
        transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type=kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:@""];
        [self.navigationController popToViewController:ctrl animated:NO];
        return;
    }
}
#pragma mark 3DTouch
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    UICollectionViewCell *cell = (UICollectionViewCell *)previewingContext.sourceView;
    IPLog(@"%@",NSStringFromCGRect(previewingContext.sourceRect));
    NSIndexPath *path = [self.mainView indexPathForCell:cell];
    IPAssetModel *model = self.curImageModelArr[path.item];
    
    __block IP3DTouchPreviewVC *reader = [IP3DTouchPreviewVC previewViewControllerWithModel:model];
    
    reader.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 0);
    return reader;
    
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    
    UICollectionViewCell *cell = (UICollectionViewCell *)previewingContext.sourceView;
    
    NSIndexPath *path = [self.mainView indexPathForCell:cell];
    
    NSUInteger currentPage = path.item;
    if (self.canTakeVideo || self.canTakePhoto) {
        currentPage -= 1;
    }
    IPImageReaderViewController *reader = [[IPImageReaderViewController alloc]init];
    reader.dataSource = self;
    [reader setUpCurrentSelectPage:currentPage];
    reader.maxSelectCount = self.maxCount;
    reader.currentSelectCount = self.selectPhotoCount;
    reader.delegate = self;
    reader.forceTouch = YES;
    [self showViewController:reader sender:self];
    
}

#pragma mark 拍照
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
    IPLog(@"didFinishPickingImage");
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    IPLog(@"didFinishPickingMediaWithInfo");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    IPLog(@"imagePickerControllerDidCancel");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark transition 
#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    if ([toVC isKindOfClass:[IPImageReaderViewController class]]) {
        if (operation == UINavigationControllerOperationPush) {
            IPAnimationTranstion *transition = [[IPAnimationTranstion alloc]init];
            return transition;
        }else if (operation == UINavigationControllerOperationPop) {
            IPAnimationInverseTransition *transition = [[IPAnimationInverseTransition alloc]init];
            return transition;
        }else {
            return nil;
        }
        
    }
    else if ([toVC isKindOfClass:[IPTakePhotoViewController class]]) {
        if (operation == UINavigationControllerOperationPush) {
            IPAnimationTakePhotoTransition *transition = [[IPAnimationTakePhotoTransition alloc]init];
            return nil;
        }else if (operation == UINavigationControllerOperationPop) {
            
            return nil;
        }else {
            return nil;
        }
        
    }else{
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    IPPresentAnimationTranstion *transition = [[IPPresentAnimationTranstion alloc]init];
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    IPPresentAnimationTranstion *transition = [[IPPresentAnimationTranstion alloc]init];
    return transition;
}

- (void)didClickCancelBtnInTakePhotoViewController:(IPTakePhotoViewController *)takePhotoViewController
{
    IPImageCell *cell = (IPImageCell *)[self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [cell setUpCameraPreviewLayer];
    
//    [takePhotoViewController dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)VisionDidClickCancelBtn:(IPTakeVideoViewController *)takevideoVC
{
    [self dismissViewControllerAnimated:takevideoVC completion:^{
//        IPImageCell *cell = (IPImageCell *)[self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//        [cell setUpCameraPreviewLayer];
    }];
}


- (UICollectionViewCell *)targetCellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    if (self.canTakePhoto || self.canTakeVideo) {
        item += 1;
    }
    return [self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item inSection:section]];
}

#pragma mark - ImageReader

- (NSUInteger)numberOfAssetsInImageReader:(IPImageReaderViewController *)imageReader
{
    return self.curImageModelArr.count;
}

- (IPImageSourceType)imageReader:(IPImageReaderViewController *)imageReader soureTypeWithIndex:(NSUInteger)index
{
    return IPImageSourceTypeAlbum;
}

- (id)imageReader:(IPImageReaderViewController *)imageReader albumAssetWithIndex:(NSUInteger)index
{
    if (self.canTakePhoto || self.canTakeVideo) {
        index += 1; 
    }
    IPAssetModel *model = self.curImageModelArr[index];
    return model.asset;
}

- (BOOL)imageReader:(IPImageReaderViewController *)imageReader currentAssetIsSelected:(NSUInteger)index
{
    if (self.canTakePhoto || self.canTakeVideo) {
        index += 1;
    }
    IPAssetModel *model = self.curImageModelArr[index];
    return model.isSelect;
}

- (void)imageReader:(IPImageReaderViewController *)reader currentAssetIsSelect:(BOOL)isSelect
{
    IPAssetModel *assetModel;
    NSUInteger index = reader.currentPage;
    if (self.canTakeVideo || self.canTakePhoto) {
        index += 1;
        assetModel = self.curImageModelArr[index];
    }
    
    if (isSelect) {
        [self addImageModel:assetModel WithIsAdd:YES];
        assetModel.isSelect = YES;
    } else {
        
        [self addImageModel:assetModel WithIsAdd:NO];
        assetModel.isSelect = NO;
    }
    [self.mainView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

#pragma mark - 配置数据
- (IPAssetModel *)setUpTakePhotoData
{
    __weak typeof(self) weakSelf = self;
    IPAssetModel *model = [[IPAssetModel alloc]init];
    model.assetType = IPAssetModelMediaTypeTakePhoto;
    AVCaptureVideoPreviewLayer *layer = [IPMediaCenter defaultCenter].previewLayer;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    model.previewLayer = layer;
    
    [[IPMediaCenter defaultCenter] startPreview];
    model.cellClickBlock = ^(id object){
        
        IPTakePhotoViewController *takePhotoVC =[[IPTakePhotoViewController alloc]init];
        takePhotoVC.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:takePhotoVC animated:YES];
    };
    return model;
}
- (IPAssetModel *)setUpTakeVideoData
{
    __weak typeof(self) weakSelf = self;
    IPAssetModel *model = [[IPAssetModel alloc]init];
    model.assetType = IPAssetModelMediaTypeTakeVideo;
//    AVCaptureVideoPreviewLayer *layer = [IPMediaCenter defaultCenter].previewLayer;
//    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    model.previewLayer = layer;
//    
//    [[IPMediaCenter defaultCenter] startPreview];
    model.cellClickBlock = ^(id object){
        
        IPTakeVideoViewController *takeVideo = [[IPTakeVideoViewController alloc]init];
        takeVideo.delegate = weakSelf;
        [weakSelf presentViewController:takeVideo animated:YES completion:nil];
    };
    return model;
}
@end


