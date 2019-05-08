//
//  IPTakeMediaOverLayerView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 2019/5/7.
//  Copyright © 2019 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPTakeMediaOverLayerView : UIView


@property (nonatomic, readonly)UIButton *cancelButton;
@property (nonatomic, readonly)UIButton *takePictureButton;
@property (nonatomic, readonly)UIImageView *imageLibraryView;

@property (nonatomic, readonly)UIImageView   *focusView;

@property (nonatomic, readonly)UIButton *flashAutoButton;
@property (nonatomic, readonly)UIButton *flashOpenButton;
@property (nonatomic, readonly)UIButton *flashCloseButton;

@property (nonatomic, readonly)UIButton *cameraSwitchButton;

@property (nonatomic, readonly)BOOL      isHiddenFlashButtons;

- (void)reSetTopbar;

- (void)hiddenSelfAndBars:(BOOL)hidden;

- (void)chosedFlashButton:(UIButton *)btn;

- (void)setFlashModel:(AVCaptureFlashMode)mode;

@end

NS_ASSUME_NONNULL_END
