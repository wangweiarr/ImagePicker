//
//  IPVideoPlayerViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 2017/3/10.
//  Copyright © 2017年 JL. All rights reserved.
//

#import "IPVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "IPPrivateDefine.h"

@interface IPVideoPlayerViewController ()
@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (weak, nonatomic)  UIView *container; //播放器容器
@property (weak, nonatomic)  UIButton *playOrPause; //播放/暂停按钮

@property(nonatomic,weak) AVPlayerLayer *playerLayer;

@property (weak, nonatomic)  UIView *controlView;

/**头部标题*/
@property (nonatomic, weak)UIView *headerBackGroundView;
/**返回btn*/
@property (nonatomic, weak)UIButton *leftButton;



/**底部标题*/
@property (nonatomic, weak)UIView *bottomBackGroundView;

//播放进度
@property(nonatomic,weak)UIProgressView *playProgressView;

@property(nonatomic,weak)UILabel *currentTimeLabel;
@property(nonatomic,weak)UILabel *totalDurationLabel;

//时间监听者
@property(nonatomic,weak)id timeObserver;


@end

@implementation IPVideoPlayerViewController

- (void)dealloc{
    IPLog(@"IPVideoPlayerViewController dealloc");
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
    //必须移除时间监听者
    [_player removeTimeObserver:_timeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self addMainView];
    
    [self addHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addHeaderView{
    
    UIButton *controlView = [[UIButton alloc]initWithFrame:self.view.bounds];
    [controlView addTarget:self action:@selector(controlViewHiddenDisplay:) forControlEvents:UIControlEventTouchUpInside];
    controlView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:controlView];
    _controlView = controlView;
    
    //添加背景图
    UIView *headerBGView = [[UIView alloc]init];
    headerBGView.backgroundColor = [UIColor colorWithRed:0 green:0  blue:0 alpha:0.5];
    [controlView addSubview:headerBGView];
    self.headerBackGroundView = headerBGView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *leftBtnImage =[UIImage imageNamed:@"bar_btn_icon_returntext_white"];
    [leftBtn setImage:leftBtnImage forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.headerBackGroundView addSubview:leftBtn];
    self.leftButton = leftBtn;
    
    UIButton *playOrPause = [[UIButton alloc]init];
    [playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [playOrPause setImage:[UIImage imageNamed:@"vedio_play_big"] forState:UIControlStateNormal];
    [playOrPause setImage:[UIImage imageNamed:@"vedio_stop_big"] forState:UIControlStateSelected];
    [controlView addSubview:playOrPause];
    _playOrPause = playOrPause;
    
    
    //添加底部图
    UIView *bottomBackGroundView = [[UIView alloc]init];
    bottomBackGroundView.backgroundColor = [UIColor colorWithRed:0 green:0  blue:0 alpha:0.5];
    [controlView addSubview:bottomBackGroundView];
    _bottomBackGroundView = bottomBackGroundView;
    
    //播放/暂停按钮
    UIProgressView *progress = [[UIProgressView alloc]init];//播放进度
    progress.progressTintColor = [UIColor orangeColor];
    progress.trackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    [bottomBackGroundView addSubview:progress];
    _playProgressView = progress;
    
    UILabel *currentLabel = [[UILabel alloc]init];
    currentLabel.textAlignment = NSTextAlignmentCenter;
    currentLabel.textColor = [UIColor whiteColor];
    currentLabel.font = [UIFont systemFontOfSize:10];
    currentLabel.text = @"00:00";
    [bottomBackGroundView addSubview:currentLabel];
    _currentTimeLabel = currentLabel;
    
    UILabel *totalDurationLabel = [[UILabel alloc]init];
    totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    totalDurationLabel.textColor = [UIColor whiteColor];
    totalDurationLabel.font = [UIFont systemFontOfSize:10];
    [bottomBackGroundView addSubview:totalDurationLabel];
    _totalDurationLabel = totalDurationLabel;
    
    
    
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)addMainView{
    
    UIView *containerView = [[UIView alloc]init];
    containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:containerView];
    _container = containerView;
    
    
    //创建播放器层
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //视频填充模式
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [containerView.layer addSublayer:playerLayer];
    _playerLayer = playerLayer;
    
    
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _container.frame = self.view.bounds;
    _controlView.frame = self.view.bounds;
    _playerLayer.frame = self.view.bounds;
    
    _headerBackGroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20 + 44);
    _leftButton.frame = CGRectMake(-5, 20, 44, 44);
    
    
    _playOrPause.frame = CGRectMake(0, 0, 66, 66);
    _playOrPause.center = _container.center;
    
    
    _bottomBackGroundView.frame = CGRectMake(0, _controlView.bounds.size.height - 64, _controlView.bounds.size.width, 20 + 44);
    
    _playProgressView.frame = CGRectMake(40, _bottomBackGroundView.bounds.size.height/2, _bottomBackGroundView.bounds.size.width - 80, 20);
    
    _currentTimeLabel.frame = CGRectMake(0, CGRectGetMaxY(_playProgressView.frame) - 10, 40, 20);
    
     _totalDurationLabel.frame = CGRectMake(CGRectGetMaxX(_playProgressView.frame), CGRectGetMaxY(_playProgressView.frame) - 10, 40, 20);
    
    
}
#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    __weak typeof(self)weakSelf = self;
    //这里设置每秒执行一次
     _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:NULL usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        NSLog(@"当前已经播放%.2fs.",current/total);
        if (current) {
            int minute = (int)CMTimeGetSeconds(time)/60;
            int second = (int)CMTimeGetSeconds(time)%60;
            
            weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minute,second];
            [weakSelf.playProgressView setProgress:(current/total) animated:YES];
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            
            int minute = (int)CMTimeGetSeconds(playerItem.duration)/60;
            int second = (int)CMTimeGetSeconds(playerItem.duration)%60;
            
            _totalDurationLabel.text = [NSString stringWithFormat:@"%2d:%2d",minute,second];
            
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        //
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if(self.player.rate==0){ //说明时暂停
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
    }
}
- (void)controlViewHiddenDisplay:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _headerBackGroundView.hidden = sender.selected;
    _bottomBackGroundView.hidden = sender.selected;
    _playOrPause.hidden = sender.selected;
}


#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
}
/**
 *  初始化播放器
 *
 *  @return 播放器对象
 */
-(AVPlayer *)player{
    if (!_player) {
        
        if (_videoURL) {
           _player=[AVPlayer playerWithURL:_videoURL];
        }else if (_playerItem)
        {
            _player=[AVPlayer playerWithPlayerItem:_playerItem];
        }else{
            NSAssert(_videoURL == nil && _playerItem == nil, @"_playerItem _videoURL 不能全为空");
        }
        
        [self addProgressObserver];
        [self addObserverToPlayerItem:_player.currentItem];
    }
    return _player;
}


- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
