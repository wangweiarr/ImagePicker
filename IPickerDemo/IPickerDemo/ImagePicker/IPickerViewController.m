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
#import "IPAssetManager.h"
#import "IPImageReaderViewController.h"
#import "IPAlertView.h"
//#import "AHUIImageNameHandle.h"
//#import "AHStringUtil.h"

#define IS_Above_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IOS7_STATUS_BAR_HEGHT (IS_Above_IOS7 ? 20.0f : 0.0f)
#define headerHeight 44.0f

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
@property (nonatomic, strong)NSMutableArray *priCurrentSelArr;

/**专辑背景view*/
@property (nonatomic, strong)UIView *albumBackView;

/**图片数组的缓存*/
@property (nonatomic, strong)NSMutableDictionary *imageModelDic;

/**当前显示的图片数组*/
@property (nonatomic, strong)NSArray *curImageModelArr;

@end
static NSString *IPicker_CollectionID = @"IPicker_CollectionID";
@implementation IPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IS_Above_IOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.defaultAssetManager reloadImagesFromLibrary];
    
    [self addMainView];
    [self addHeaderView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.defaultAssetManager clearDataCache];
}
- (void)dealloc{
    NSLog(@"IPickerViewController--dealloc");
}

#pragma mark - UI -
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat headerH = IOS7_STATUS_BAR_HEGHT + headerHeight;
    CGFloat btnH = headerHeight;
    CGFloat btnW = headerHeight;
    CGFloat MaxMargin = 5.0f;
    
    
    self.headerView.frame = CGRectMake(0, 0, viewW, headerH);
    self.leftBtn.frame = CGRectMake(MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    CGSize tempSize = [IPickerViewController stringFontSizeWithString:@"这里是汽车之家的测试" font:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, btnH)];
    CGSize size = [self.centerBtn sizeThatFits:tempSize];
    if (size.width > tempSize.width) {
        size = tempSize;
    }
    self.centerBtn.frame = CGRectMake(self.headerView.center.x - size.width/2, IOS7_STATUS_BAR_HEGHT, size.width, btnH);
    self.rightBtn.frame = CGRectMake(viewW - btnW -MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    self.arrowImge.frame = CGRectMake(CGRectGetMaxX(self.centerBtn.frame), IOS7_STATUS_BAR_HEGHT, btnW/2, btnH);
    
    
    
    self.spliteView.frame = CGRectMake(0, headerH - 0.5,viewW, 0.5);
    
    self.mainView.frame = CGRectMake(0, headerH, viewW, viewH - headerH);
}
- (void)addHeaderView{
    
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor clearColor];
    [leftBtn sizeToFit];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [leftBtn.titleLabel setFontSizeKey:textfont05];
    [leftBtn addTarget:self action:@selector(exitIPicker) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [centerBtn addTarget:self action:@selector(displayAlbumView:) forControlEvents:UIControlEventTouchUpInside];
    centerBtn.contentMode = UIViewContentModeCenter;
    centerBtn.titleLabel.font = [UIFont systemFontOfSize:15];//textsize04
    centerBtn.backgroundColor = [UIColor clearColor];
    [centerBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [centerBtn setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
    [centerBtn sizeToFit];
    [headerView addSubview:centerBtn];
    self.centerBtn = centerBtn;
    
    
    UIImageView *arrowImge = [[UIImageView alloc]init];
    arrowImge.contentMode = UIViewContentModeCenter;
    UIImage *image =[UIImage imageNamed:@"common_icon_arrow"];
    [arrowImge  setImage:image];
    [headerView addSubview:arrowImge];
    self.arrowImge = arrowImge;
    
    UILabel    *rightLabel = [[UILabel alloc]init];
    rightLabel.font = [UIFont systemFontOfSize:12];
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
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
//    [rightBtn.titleLabel setFontSizeKey:textfont05];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn.userInteractionEnabled = NO;
    [headerView addSubview:rightBtn];
    rightBtn.backgroundColor = [UIColor clearColor];
    self.rightBtn = rightBtn;
    
    UIView *spliteView = [[UIView alloc]init];
    spliteView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:spliteView];
    self.spliteView = spliteView;
}

- (void)addMainView{
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
- (BOOL)shouldAutorotate{
    return NO;
}
#pragma mark - collectionview-

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.curImageModelArr.count;
}
- (IPImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IPImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IPicker_CollectionID forIndexPath:indexPath];
    IPImageModel *model = self.curImageModelArr[indexPath.item];
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
    IPImageReaderViewController *reader = [IPImageReaderViewController imageReaderViewControllerWithData:self.curImageModelArr TargetIndex:indexPath.item];
    reader.maxCount = self.maxCount;
    reader.currentCount = self.selectPhotoCount;
    reader.delegate = self;
    reader.dismissBlock = ^(){
        [self.mainView reloadData];
    };
    if (reader) {
        [self presentViewController:reader animated:YES completion:nil];
    }else {
        NSLog(@"内存吃紧啊");
    }
    
}
#pragma  mark - 导航条左右按钮的处理逻辑 -
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
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(self.presentingViewController){
        
        [self.view.layer addAnimation:transition forKey:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/**
 *  右上角 完成 按钮点击
 */
- (void)completeBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCompleteBtn:)]) {
        [self.delegate didClickCompleteBtn:[self.priCurrentSelArr copy]];
    }
    [self exitIPicker];
}
#pragma mark 点击右上角的"对勾"对应的逻辑
/**
 *  点击cell右上角的选中按钮
 */
- (BOOL)clickRightCornerBtnForView:(IPImageModel *)model{
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
- (void)clickSelectBtnForReaderView:(IPImageModel *)assetModel{
    if (assetModel.isSelect) {
        [self addImageModel:assetModel WithIsAdd:YES];
    }else {
        [self addImageModel:assetModel WithIsAdd:NO];
    }
}
- (void)addImageModel:(IPImageModel *)model WithIsAdd:(BOOL)isAdd{
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
- (void)setSelectPhotoCount:(NSUInteger)selectPhotoCount{
    if (_selectPhotoCount != selectPhotoCount) {
        _selectPhotoCount = selectPhotoCount;
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
- (void)displayAlbumView:(UIButton *)btn{
    
    [self.centerBtn setTitle:@"选择相册" forState:UIControlStateNormal];
    if (_albumView == nil) {
        _albumView = [IPAlbumView albumViewWithData:self.defaultAssetManager.albumArr];
        _albumView.delegate =self;
        NSInteger currentIndex = (NSInteger)[self.defaultAssetManager.albumArr indexOfObject:self.defaultAssetManager.currentAlbumModel];
        [_albumView selectAlbumViewCellForIndex:currentIndex];
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
- (void)shouldRemoveFrom:(IPAlbumView *)view{
    
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
- (void)clickCellForIndex:(NSIndexPath *)indexPath ForView:(IPAlbumView *)View{
    IPAlbumModel *model = [self.defaultAssetManager.albumArr objectAtIndex:indexPath.item];
    [self.centerBtn setTitle:model.albumName forState:UIControlStateNormal];
    self.defaultAssetManager.currentAlbumModel = model;
    [self shouldRemoveFrom:View];
    self.selectPhotoCount = self.priCurrentSelArr.count;
    
    if ([self.imageModelDic objectForKey:model.albumName]) {
        self.curImageModelArr = [self.imageModelDic objectForKey:model.albumName];
        [self.mainView reloadData];
    }else {
        [self.defaultAssetManager getImagesForAlbumUrl:model.groupURL];
    }
    
    
    
    
}
#pragma mark 获取相册的所有图片

- (void)loadImageDataFinish:(IPAssetManager *)manager{
    if (manager.currentPhotosArr.count == 0) {
        NSString *message = @"请在设置->通用->访问限制->照片 启用访问图片的权限!";
        if ([[[UIDevice currentDevice]systemVersion]floatValue]<6.0) {
            message = @"请在设置->通用->访问限制->位置 启用定位服务!";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"图片访问失败" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alertView show];
        
        [self.centerBtn setTitle:@"访问相册失败" forState:UIControlStateNormal];
        [self.centerBtn sizeToFit];
        [self.view setNeedsLayout];
        
        return;
    }
    
    self.curImageModelArr = [NSArray arrayWithArray:self.defaultAssetManager.currentPhotosArr];
    [self.imageModelDic setObject:self.curImageModelArr forKey:self.defaultAssetManager.currentAlbumModel.albumName];
    
    if ([[NSThread currentThread] isMainThread]) {
        [self.mainView reloadData];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainView reloadData];
        });
    }
}
+ (void)getImageModelWithURL:(NSURL *)url CreatBlock:(CreatImageModelBlock)block{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:url resultBlock:^(ALAsset *asset) {
        IPImageModel *model = [[IPImageModel alloc]init];
        model.alasset = asset;
        model.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        model.fullRorationImage = [UIImage imageWithCGImage:representation.fullScreenImage];
        if (block) {
            block(model);
        }
    } failureBlock:^(NSError *error) {
        
    }];
}
#pragma mark - alert框的处理 -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self exitIPicker];
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
+ (CGSize)stringFontSizeWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size
{
    if (string == nil || [string isEqualToString:@""] || font == nil){
        
        return CGSizeMake(0, 0);
    }
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string
                                                                         attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    return rect.size;
}
@end
