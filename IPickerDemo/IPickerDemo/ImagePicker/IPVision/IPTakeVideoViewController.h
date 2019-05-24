//
//  IPTakeVideoViewController.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/4/11.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "IPVision.h"
#import "IPMediaCenter.h"

#pragma mark - ClubVisionViewControllerDelegate

@class IPTakeVideoViewController;
@protocol IPTakeVideoViewControllerDelegate <NSObject>

@optional
//-(void)visionDidCaptureFinish:(IPVision *)vision withThumbnail:(NSURL *)thumbnail withVideoDuration:(float)duration;

-(void)visionDidCaptureFinish:(IPMediaCenter *)vision withThumbnail:(NSURL *)thumbnail withVideoDuration:(float)duration;
-(void)visionDidClickCancelBtn:(IPTakeVideoViewController *)takevideoVC;
@end


@interface IPTakeVideoViewController : UIViewController
@property(nonatomic,assign) id<IPTakeVideoViewControllerDelegate> delegate;

@property(nonatomic,assign) Float64 maximumCaptureDuration;
@property(nonatomic,assign) Float64 minimumCaptureDuration;
@property(nonatomic,assign) CGFloat exportVideoWidth;
@property(nonatomic,assign) CGFloat exportVideoHeight;
/*
 AVAssetExportPresetLowQuality=3
 AVAssetExportPresetMediumQuality=2
 AVAssetExportPresetHighestQuality=1
 */
@property(nonatomic,assign) NSInteger exportPresetQuality;
@end
