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

#define IS_Above_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IOS7_STATUS_BAR_HEGHT (IS_Above_IOS7 ? 20.0f : 0.0f)

@interface IPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,IPAlbumViewDelegate,IPAssetManagerDelegate>
/**图库*/
@property (nonatomic, strong)IPAssetManager *defaultAssetManager;


/**头部视图*/
@property (nonatomic, weak)UIView *headerView;

/**头部视图*/
@property (nonatomic, weak)UIButton *leftBtn;

/**中部视图*/
@property (nonatomic, weak)UIButton *centerBtn;

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

@end
static NSString *IPicker_CollectionID = @"IPicker_CollectionID";
@implementation IPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadImagesFromLibrary];
    [self addHeaderView];
    [self addMainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - visible -
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat headerH = IOS7_STATUS_BAR_HEGHT + 44.0f;
    CGFloat btnH = 44.0f;
    CGFloat btnW = 44.0f;
    CGFloat centerBtnW = 100.0f;
    CGFloat MaxMargin = 10.0f;
    CGFloat MinMargin = 5.0f;
    
    CGFloat labelW = 20.0f;
    self.headerView.frame = CGRectMake(0, 0, viewW, headerH);
    self.leftBtn.frame = CGRectMake(MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    self.centerBtn.frame = CGRectMake(self.headerView.center.x - centerBtnW/2, IOS7_STATUS_BAR_HEGHT, centerBtnW, btnH);
    self.rightBtn.frame = CGRectMake(viewW - btnW -MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
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
    [centerBtn sizeToFit];
    [centerBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [centerBtn setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
    [headerView addSubview:centerBtn];
    self.centerBtn = centerBtn;
    
    UILabel    *rightLabel = [[UILabel alloc]init];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.clipsToBounds = YES;
    rightLabel.textColor = [UIColor whiteColor];
    [rightLabel setBackgroundColor:[UIColor blueColor]];
    [rightLabel setText:@"5"];
    [rightLabel sizeToFit];
    [headerView addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn sizeToFit];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
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
    mainView.backgroundColor = [UIColor blackColor];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  点击cell右上角的选中按钮
 */
- (void)clickRightCornerBtnInCell:(UIButton *)btn{
    
}
/**
 *  点击中部相册名称,展示相册列表
 */
- (void)displayAlbumView:(UIButton *)btn{
   
    if (_albumView == nil) {
        _albumView = [IPAlbumView albumViewWithData:self.defaultAssetManager.albumArr];
        _albumView.delegate =self;
        
        [_albumView setFrame:CGRectMake(0,-(self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - 44) , self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - 44)];
    }
    
    if (_albumView.superview) {
        return;
    }
    
    [self.view addSubview:_albumView];
    [UIView animateWithDuration:0.3 animations:^{
        _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        NSLog(@"显示专辑列表");
    }];
    
}
/**
 *  将专辑列表移除
 */
- (void)shouldRemoveFrom:(IPAlbumView *)view{
    [UIView animateWithDuration:0.3 animations:^{
        _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [_albumView removeFromSuperview];
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
    [self.defaultAssetManager getImagesForAlbumUrl:model.groupURL];
    [self shouldRemoveFrom:nil];
}
#pragma mark - lazy -
- (IPAssetManager *)defaultAssetManager{
    if (_defaultAssetManager == nil) {
        _defaultAssetManager = [IPAssetManager defaultAssetManager];
        _defaultAssetManager.delegate = self;
    }
    return _defaultAssetManager;
}


#pragma mark 获取相册的所有图片
- (void)reloadImagesFromLibrary
{
    [self.defaultAssetManager reloadImagesFromLibrary];
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
                if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                    NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
                }else{
                    NSLog(@"相册访问失败.");
                }
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        IPImageModel *imgModel = [[IPImageModel alloc]init];
                        
                        imgModel.alasset = result;
                        
                        imgModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                        
                        imgModel.url = [result valueForProperty:ALAssetPropertyAssetURL];
                        
                        [self.currentPhotosArr addObject:imgModel];
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    NSLog(@"遍历完毕");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mainView reloadData];
                    });
                    
                }
                
                if (group!=nil) {
                    NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                    NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                    
                    IPAlbumModel *model = [[IPAlbumModel alloc]init];
                    model.posterImage = [UIImage imageWithCGImage:group.posterImage];
                    model.imageCount = group.numberOfAssets;
                    
                    if ([(NSString *)[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                        model.albumName =@"相机胶卷";
                    }else {
                        model.albumName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                    }
                    
                    model.groupURL = (NSURL *)[group valueForProperty:ALAssetsGroupPropertyURL];
                    
                    [self.albumArr addObject:model];
                    
                    if ([model.albumName isEqualToString:@"相机胶卷"]) {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    }
                    
                }
                
            };
            
            [self.defaultLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                               usingBlock:libraryGroupsEnumeration
                                             failureBlock:failureblock];
        }
        
    });
     */
}
- (void)loadImageDataFinish:(IPAssetManager *)manager{
    if ([[NSThread currentThread] isMainThread]) {
        [self.mainView reloadData];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainView reloadData];
        });
    }
}
@end
