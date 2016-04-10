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

#import <Photos/Photos.h>

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
static UIViewController *vc;
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
    NSLog(@"%@",vc);
    vc = [[UIViewController alloc]init];
    NSLog(@"%@",vc);
    
}
- (IBAction)popIPicker:(UIButton *)sender{
    IPickerViewController *ip = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleImage];
    ip.delegate = self;
    ip.maxCount = 50;
    ip.popStyle = IPickerViewControllerPopStylePush;
    [self.navigationController pushViewController:ip animated:YES];
//    [self presentViewController:ip animated:YES completion:nil];
    vc = nil;
//    free((__bridge void *)(vc));
    if ([vc isEqual:[NSNull null]]) {
        NSLog(@"vc已经被释放了");
    }
     NSLog(@"%@",vc);
}
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didClickCompleteBtn:(NSArray *)datas{
   [datas enumerateObjectsUsingBlock:^(IPImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       NSLog(@"%@--%@",obj.localIdentiy,obj.assetUrl.absoluteString);
       if (idx == 0) {
                       [IPickerViewController getImageModelWithURL:obj.assetUrl RequestBlock:^(UIImage *image, NSDictionary *info) {
                           _img1.image = image;
                       }];
                   }else if (idx == 1){
                       [IPickerViewController getImageModelWithURL:obj.assetUrl RequestBlock:^(UIImage *image, NSDictionary *info) {
                           _img2.image = image;
                       }];
                   }else if (idx == 2){
                       [IPickerViewController getImageModelWithURL:obj.assetUrl RequestBlock:^(UIImage *image, NSDictionary *info) {
                           _img3.image = image;
                       }];
                   }else if (idx == 3){
                       [IPickerViewController getImageModelWithURL:obj.assetUrl RequestBlock:^(UIImage *image, NSDictionary *info) {
                           _img4.image = image;
                       }];
                   }
   }];
    
}


@end
