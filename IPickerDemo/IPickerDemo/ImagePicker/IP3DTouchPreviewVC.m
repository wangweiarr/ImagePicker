//
//  IP3DTouchPreviewVC.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/4/23.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IP3DTouchPreviewVC.h"
#import "IPAssetModel.h"
#import "IPAssetManager.h"

@interface IP3DTouchPreviewVC ()
/**数据模型*/
@property (nonatomic, strong)IPAssetModel *dataModel;



@end

@implementation IP3DTouchPreviewVC
+ (instancetype)previewViewControllerWithModel:(IPAssetModel *)model{
    IP3DTouchPreviewVC *vc = [[self alloc]init];
    vc.dataModel = model;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.cornerRadius = 5;
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imgView = imgView;
    [self.view addSubview:imgView];
}

- (void)cancle{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self)weakSelf = self;
    [[IPAssetManager defaultAssetManager]getFullScreenImageWithAsset:self.dataModel photoWidth:self.view.bounds.size completion:^(UIImage *photo, NSDictionary *info) {
//        CGFloat imgH = photo.size.width * [UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width;
//        NSLog(@"%f",imgH);
//        weakSelf.preferredContentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height * (imgH/[UIScreen mainScreen].bounds.size.width)/([UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width) );
        weakSelf.imgView.image = photo;
    }];
}
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    // setup a list of preview actions
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"I" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Aciton1%@",previewViewController);
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"LOVE" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"action2%@",previewViewController);
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"YOU" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"action3%@",previewViewController);
    }];
    
    NSArray *actions = @[action1,action2,action3];
    
    // and return them (return the array of actions instead to see all items ungrouped)
    return actions;
}
@end
