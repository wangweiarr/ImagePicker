//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/25.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "ViewController.h"
#import "IPickerViewController.h"
#import "IPAssetManager.h"

@interface ViewController ()<IPickerViewControllerDelegate>
/**sdf*/
@property (nonatomic, strong)NSArray *arr;

/**d*/
@property (nonatomic, strong)UIImageView *img1;
@property (nonatomic, strong)UIImageView *img2;
@property (nonatomic, strong)UIImageView *img3;
@property (nonatomic, strong)UIImageView *img4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _img1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 100, 100)];
    [self.view addSubview:_img1];
    _img2 = [[UIImageView alloc]initWithFrame:CGRectMake(130, 50, 100, 100)];
    [self.view addSubview:_img2];
    _img3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 170, 100, 100)];
    [self.view addSubview:_img3];
    _img4 = [[UIImageView alloc]initWithFrame:CGRectMake(130, 170, 100, 100)];
    [self.view addSubview:_img4];
    
}
- (IBAction)popIPicker:(UIButton *)sender{
    IPickerViewController *ip = [[IPickerViewController alloc]init];
    ip.delegate = self;
    ip.maxCount = 11;
    ip.popStyle = IPickerViewControllerPopStylePush;
    [self.navigationController pushViewController:ip animated:YES];
    //    [self presentViewController:ip animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didClickCompleteBtn:(NSArray *)datas{
    NSLog(@"%@",datas);
    
    [datas enumerateObjectsUsingBlock:^(IPImageModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [IPickerViewController getImageModelWithURL:obj.assetUrl CreatBlock:^(IPImageModel *obg) {
                _img1.image = obg.thumbnail;
            }];
        }else if (idx == 1){
            [IPickerViewController getImageModelWithURL:obj.assetUrl CreatBlock:^(IPImageModel *obg) {
                _img2.image = obg.thumbnail;
            }];
        }else if (idx == 2){
            [IPickerViewController getImageModelWithURL:obj.assetUrl CreatBlock:^(IPImageModel *obg) {
                _img3.image = obg.fullRorationImage;
            }];
        }else if (idx == 3){
            [IPickerViewController getImageModelWithURL:obj.assetUrl CreatBlock:^(IPImageModel *obg) {
                _img4.image = obg.fullRorationImage;
            }];
        }
    }];
}
@end
