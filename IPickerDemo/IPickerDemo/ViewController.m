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
//    D7DD1D1D-DC89-4A5A-B30F-E735F3589C19/L0/001
    
    
}
- (IBAction)pickerVideo:(UIButton *)sender {
    IPickerViewController *ip = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleVideo];
    ip.delegate = self;
    ip.maxCount = 9;
    ip.popStyle = IPickerViewControllerPopStylePush;
    [self.navigationController pushViewController:ip animated:YES];
}

- (IBAction)popIPicker:(UIButton *)sender{
    IPickerViewController *ip = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleImage];
    ip.delegate = self;
    ip.maxCount = 9;
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
   [datas enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       NSLog(@"%@--%@",obj.localIdentiy,obj.assetUrl.absoluteString);
       if (idx == 0) {
                   }else if (idx == 1){
                       
                   }else if (idx == 2){
                       
                   }else if (idx == 3){
                       
                   }
   }];
    
}
- (void)didFinishCaptureVideoUrl:(NSURL *)videourl videoDuration:(float)duration thumbailImage:(NSURL *)thumbailUrl{
    UIImage *thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbailUrl
                                                      ]];
    
    [_img2 setImage:thumbnailImage];
}

@end
