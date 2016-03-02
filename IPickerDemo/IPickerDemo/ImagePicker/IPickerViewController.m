//
//  IPickerViewController.m
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPickerViewController.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPImageModel.h"
#import "IPAssetManager.h"
#import "IPImageReaderViewController.h"
#import "IPAlertView.h"

#define IS_Above_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IOS7_STATUS_BAR_HEGHT (IS_Above_IOS7 ? 20.0f : 0.0f)


@interface IPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,IPAlbumViewDelegate,IPAssetManagerDelegate,IPImageCellDelegate,IPImageReaderViewControllerDelegate>
/**图库*/
@property (nonatomic, strong)IPAssetManager *defaultAssetManager;


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
@property (nonatomic, strong)NSMutableArray *pri_currentSelArr;

@end
static NSString *IPicker_CollectionID = @"IPicker_CollectionID";
@implementation IPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.defaultAssetManager reloadImagesFromLibrary];
    
    [self addMainView];
    [self addHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    NSLog(@"IPickerViewController--dealloc");
}
#pragma mark - visible -
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat headerH = IOS7_STATUS_BAR_HEGHT + 44.0f;
    CGFloat btnH = 44.0f;
    CGFloat btnW = 44.0f;
    CGFloat centerBtnW = 88.0f;
    CGFloat MaxMargin = 10.0f;
    CGFloat MinMargin = 5.0f;
    
    CGFloat labelW = 20.0f;
    self.headerView.frame = CGRectMake(0, 0, viewW, headerH);
    self.leftBtn.frame = CGRectMake(MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    CGSize size = [self.centerBtn sizeThatFits:CGSizeMake(centerBtnW, btnH)];
    self.centerBtn.frame = CGRectMake(self.headerView.center.x - size.width/2, IOS7_STATUS_BAR_HEGHT, size.width, btnH);
    self.rightBtn.frame = CGRectMake(viewW - btnW -MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    self.arrowImge.frame = CGRectMake(CGRectGetMaxX(self.centerBtn.frame), IOS7_STATUS_BAR_HEGHT, btnW/2, btnH);
    
    self.rightLabel.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame) - MinMargin - labelW, IOS7_STATUS_BAR_HEGHT+13, labelW, labelW);
    self.rightLabel.layer.cornerRadius = labelW/2;
    
    self.spliteView.frame = CGRectMake(0, headerH - 0.5,viewW, 0.5);
    
    self.mainView.frame = CGRectMake(0, headerH, viewW, viewH - headerH);
}
- (void)addHeaderView{
    
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9]];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn sizeToFit];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(exitIPicker) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [headerView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [centerBtn addTarget:self action:@selector(displayAlbumView:) forControlEvents:UIControlEventTouchUpInside];
    centerBtn.contentMode = UIViewContentModeCenter;
    
    [centerBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [centerBtn setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
    [centerBtn sizeToFit];
    [headerView addSubview:centerBtn];
    self.centerBtn = centerBtn;
    
    
    UIImageView *arrowImge = [[UIImageView alloc]init];
    arrowImge.contentMode = UIViewContentModeCenter;
    [arrowImge  setImage:[UIImage imageNamed:@"icon_arrow_blue"]];
    [headerView addSubview:arrowImge];
    self.arrowImge = arrowImge;
    
    UILabel    *rightLabel = [[UILabel alloc]init];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.clipsToBounds = YES;
    rightLabel.textColor = [UIColor whiteColor];
    [rightLabel setBackgroundColor:[UIColor blueColor]];
    [rightLabel setText:@""];
    [rightLabel sizeToFit];
    rightLabel.hidden = YES;
    [headerView addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn sizeToFit];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:rightBtn];
    self.rightBtn = rightBtn;
    
    UIView *spliteView = [[UIView alloc]init];
    spliteView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:spliteView];
    self.spliteView = spliteView;
}

- (void)addMainView{
    _flowOut = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *mainView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowOut];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.delegate = self;
    mainView.dataSource = self;
    [mainView registerClass:[IPImageCell class] forCellWithReuseIdentifier:IPicker_CollectionID];
    self.mainView = mainView;
    [self.view addSubview:mainView];
}

#pragma mark - collectionview-

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.defaultAssetManager.currentPhotosArr.count;
}
- (IPImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IPImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IPicker_CollectionID forIndexPath:indexPath];
    IPImageModel *model = self.defaultAssetManager.currentPhotosArr[indexPath.item];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger rowCount = 4;
    NSUInteger margin = 5;
    CGFloat itemWidth = (collectionView.frame.size.width - (rowCount-1)*margin)/rowCount;
    return CGSizeMake(itemWidth, itemWidth);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IPImageReaderViewController *reader = [IPImageReaderViewController imageReaderViewControllerWithData:self.defaultAssetManager.currentPhotosArr TargetIndex:indexPath.item];
    reader.maxCount = self.maxCount;
    reader.currentCount = self.selectPhotoCount;
    reader.delegate = self;
    reader.dismissBlock = ^(){
        [self.mainView reloadData];
    };
    [self presentViewController:reader animated:YES completion:nil];
}
#pragma  mark - action -
/**
 *  左上角的取消按钮点击
 */
- (void)exitIPicker{
    
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
        [self.navigationController popViewControllerAnimated:NO];
        
    }else if (self.isBeingPresented) {
        
        [self.view.layer addAnimation:transition forKey:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
/**
 *  右上角 完成 按钮点击
 */
- (void)completeBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCompleteBtn:)]) {
        [self.delegate didClickCompleteBtn:[self.pri_currentSelArr copy]];
    }
    [self exitIPicker];
}
/**
 *  点击cell右上角的选中按钮
 */
- (BOOL)clickRightCornerBtnForView:(IPImageModel *)model{
    if (model.isSelect) {
        if (self.selectPhotoCount >= self.maxCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxCount];
            return NO;
        }
        self.selectPhotoCount++;
        if (![self.pri_currentSelArr containsObject:model]) {
            [self.pri_currentSelArr addObject:model];
        }
    }else {
        self.selectPhotoCount--;
        if ([self.pri_currentSelArr containsObject:model]) {
            [self.pri_currentSelArr removeObject:model];
        }
    }
    return YES;
}
/**
 *  点击大图浏览时的选中按钮的代理回调方法
 *
 *  @param assetModel 对应的imageModel对象
 */
- (void)clickSelectBtnForReaderView:(IPImageModel *)assetModel{
    if (assetModel.isSelect) {
        self.selectPhotoCount++;
        [self.pri_currentSelArr addObject:assetModel];
        if (![self.pri_currentSelArr containsObject:assetModel]) {
            [self.pri_currentSelArr addObject:assetModel];
        }
    }else {
        self.selectPhotoCount--;
        if ([self.pri_currentSelArr containsObject:assetModel]) {
            [self.pri_currentSelArr removeObject:assetModel];
        }
        
    }
}
- (void)setSelectPhotoCount:(NSUInteger)selectPhotoCount{
    if (_selectPhotoCount != selectPhotoCount) {
        _selectPhotoCount = selectPhotoCount;
        if (_selectPhotoCount == 0) {
            self.rightLabel.hidden = YES;
        }else {
            self.rightLabel.hidden = NO;
        }
        
        [self.rightLabel setText:[NSString stringWithFormat:@"%tu",_selectPhotoCount]];
    }
}

/**
 *  点击中部相册名称,展示相册列表
 */
- (void)displayAlbumView:(UIButton *)btn{
   
    if (_albumView == nil) {
        _albumView = [IPAlbumView albumViewWithData:self.defaultAssetManager.albumArr];
        _albumView.delegate =self;
        
        [_albumView setFrame:CGRectMake(0,-(self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - 44) , self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - 44)];
        NSLog(@"创建专辑列表--%@",NSStringFromCGRect(_albumView.frame));
        NSInteger currentIndex = (NSInteger)[self.defaultAssetManager.albumArr indexOfObject:self.defaultAssetManager.currentAlbumModel];
        [_albumView selectAlbumViewCellForIndex:currentIndex];
    }
    
    if (_albumView.superview) {
        [self shouldRemoveFrom:nil];
        return;
    }
    [self.view insertSubview:_albumView belowSubview:self.headerView];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.arrowImge.transform = CGAffineTransformRotate(self.arrowImge.transform,M_PI);
        
        _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
        NSLog(@"显示专辑列表--%@",NSStringFromCGRect(_albumView.frame));
    }];
    
}
/**
 *  将专辑列表移除
 */
- (void)shouldRemoveFrom:(IPAlbumView *)view{
    [UIView animateWithDuration:0.3 animations:^{
         self.arrowImge.transform = CGAffineTransformRotate(self.arrowImge.transform,-M_PI);
        _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [_albumView removeFromSuperview];
        NSLog(@"隐藏专辑列表--%@",NSStringFromCGRect(_albumView.frame));
    }];
}
/**
 *  选中专辑列表的某个cell时的回调方法
 *
 *  @param indexPath 点击对应的索引
 *  @param View      专辑列表 view
 */
- (void)clickCellForIndex:(NSIndexPath *)indexPath ForView:(IPAlbumView *)View{
    IPAlbumModel *model = [self.defaultAssetManager.albumArr objectAtIndex:indexPath.item];
    [self.centerBtn setTitle:model.albumName forState:UIControlStateNormal];
    [self.defaultAssetManager getImagesForAlbumUrl:model.groupURL];
    [self shouldRemoveFrom:nil];
    self.selectPhotoCount = 0;
    
}
#pragma mark 获取相册的所有图片

- (void)loadImageDataFinish:(IPAssetManager *)manager{
    if ([[NSThread currentThread] isMainThread]) {
        [self.mainView reloadData];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainView reloadData];
        });
    }
}
+ (UIImage *)getFullRotationScreenImage:(IPImageModel *)imageModel{
    return [IPAssetManager getFullScreenImage:imageModel];
}
#pragma mark - lazy -
- (IPAssetManager *)defaultAssetManager{
    if (_defaultAssetManager == nil) {
        _defaultAssetManager = [IPAssetManager defaultAssetManager];
        _defaultAssetManager.delegate = self;
    }
    return _defaultAssetManager;
}


- (void)setMaxCount:(NSUInteger)maxCount{
    NSInteger tempCount = (NSInteger)maxCount;
    if (_maxCount != tempCount && tempCount > 0) {
        _maxCount = tempCount;
    }else {
        _maxCount = 50;
    }
}

- (NSMutableArray *)pri_currentSelArr{
    if (_pri_currentSelArr == nil) {
        _pri_currentSelArr = [NSMutableArray arrayWithCapacity:self.maxCount];
    }
    return _pri_currentSelArr;
}
@end
