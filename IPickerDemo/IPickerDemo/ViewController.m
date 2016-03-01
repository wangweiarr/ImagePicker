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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)test:(UIButton *)sender {
    NSLog(@"%@",[IPAssetManager defaultAssetManager]);
}
- (IBAction)entryImagePicker {
    IPickerViewController *vc = [[IPickerViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
