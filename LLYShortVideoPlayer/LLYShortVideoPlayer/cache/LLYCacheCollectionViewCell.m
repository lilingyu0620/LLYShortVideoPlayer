//
//  LLYCacheCollectionViewCell.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/21.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYCacheCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import "LLYShortVideoResourceLoader.h"

@interface LLYCacheCollectionViewCell ()

@property (nonatomic, strong) AVPlayer *mPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) CGFloat preparePlayTime;
@property (nonatomic, assign) CGFloat startPlayTime;

@property (nonatomic, strong) UILabel *startTimeLabel;

@property (nonatomic, assign) NSInteger curIdx;

@end

@implementation LLYCacheCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
    
    [self.contentView.layer addSublayer:self.playerLayer];
    
    [self.contentView addSubview:self.startTimeLabel];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(OCWidth, 30));
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
}


- (void)configWithUrl:(NSString *)urlStr idx:(NSInteger)idx{
    
    self.curIdx = idx;
    
    LLYShortVideoResourceLoader *loader = [[LLYShortVideoResourceLoader alloc]init];
    
    self.playerItem = [loader playerItemWithUrl:urlStr];
    self.mPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer.player = self.mPlayer;
    
    if (self.mPlayer.currentItem) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotContinueNotification:) name:AVPlayerItemPlaybackStalledNotification object:self.mPlayer.currentItem];
        
        [self.mPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:nil];
        [self.mPlayer.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.mPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];//监听状态。播放还是暂停或者其他
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayer.currentItem];
    }
    
    self.preparePlayTime = CFAbsoluteTimeGetCurrent();
    //    NSLog(@"preparePlayTime = %f",self.preparePlayTime);
}

- (void)play{
    
    [self.mPlayer play];
}

- (void)stop{
    [self.mPlayer pause];
    //    self.playerItem = nil;
    //
    //    [self.mPlayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    //    [self.mPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    //    [self.mPlayer removeObserver:self forKeyPath:@"rate" context:nil];
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer layer];
        [_playerLayer setFrame:CGRectMake(0, 0, OCWidth, OCHeight)];
        _playerLayer.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 256.0 green:arc4random() % 255 / 256.0 blue:arc4random() % 255 / 256.0 alpha:1.0].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}


- (void)cannotContinueNotification:(NSNotification *)notification {
    NSLog(@"视频播放失败！！！");
}

//KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        
        if (playerItem.status == AVPlayerStatusReadyToPlay){
            //            NSLog(@"AVPlayerStatusReadyToPlay");
            
            self.startPlayTime = CFAbsoluteTimeGetCurrent();
            //            NSLog(@"startPlayTime = %f",self.startPlayTime);
            //            NSLog(@"<<<<<<<<<<<<<<<<首屏时间：%f>>>>>>>>>>>>>",self.startPlayTime-self.perparePlayTime);
            self.startTimeLabel.text = [NSString stringWithFormat:@"pathindex = %ld,首屏时间：%f",self.curIdx,self.startPlayTime-self.preparePlayTime];
            
        }else if (playerItem.status == AVPlayerStatusFailed){//视频加载失败==发通知==无法播放==弹提示框，加载下一个视频等操作。
            //            NSLog(@"AVPlayerStatusFailed");
        }else if (playerItem.status == AVPlayerStatusUnknown) {
            //            NSLog(@"AVPlayerStatusUnknown");
        }
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //        NSTimeInterval timeInterval = [self p_availableDuration];// 计算缓冲进度
        //        NSLog(@"timeInterval = %f",timeInterval);
    }
    
    if ([keyPath isEqualToString:@"rate"])  {//速率为0时候，是暂停或者停止，速率为1，是正在播放
        //速率为0 的时候，播放实际上停止了，此时也停止字幕的播放
        
        if (self.mPlayer.rate == 1) {
            //            NSLog(@"播放速度变为1");
        }else if (self.mPlayer.rate == 0) {
            //            NSLog(@"播放速度变为0");
        }
        
    }
}

//视频播放完毕
- (void)playerItemDidReachEnd:(NSNotification *)notification{
    //    NSLog(@"playerItemDidReachEnd");
    [self.mPlayer seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.mPlayer play];
    }];
    
    
}

- (NSTimeInterval)p_availableDuration {
    NSArray *loadedTimeRanges = [[self.mPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (UILabel *)startTimeLabel{
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc]init];
        if (@available(iOS 8.2, *)) {
            _startTimeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            // Fallback on earlier versions
        }
        _startTimeLabel.textColor = [UIColor redColor];
        _startTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _startTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _startTimeLabel;
}

@end
