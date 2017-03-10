//
//  IPVideoPlayerViewController.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/3/10.
//  Copyright © 2017年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayerItem;
@interface IPVideoPlayerViewController : UIViewController

@property(nonatomic,strong) NSURL *videoURL;
@property(nonatomic,strong) AVPlayerItem *playerItem;
@end
