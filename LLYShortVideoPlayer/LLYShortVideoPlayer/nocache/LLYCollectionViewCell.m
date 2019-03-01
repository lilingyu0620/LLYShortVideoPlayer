//
//  LLYCollectionViewCell.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/20.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYCollectionViewCell.h"
#import <Masonry.h>
#import "LLYShortVideoPreloadManager.h"

@interface LLYCollectionViewCell ()

@property (nonatomic, assign) CGFloat preparePlayTime;
@property (nonatomic, assign) CGFloat startPlayTime;

@property (nonatomic, strong) UILabel *startTimeLabel;

@property (nonatomic, assign) NSInteger curIdx;

@end

@implementation LLYCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
        
    [self.contentView addSubview:self.startTimeLabel];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(OCWidth, 30));
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];

}


- (void)configWithUrl:(NSString *)urlStr idx:(NSInteger)idx{
        
    self.curIdx = idx;
    self.url = urlStr;
    
    [[LLYShortVideoPreloadManager sharedInstance] addCell:self];
}

- (void)addObs{
    
    if (self.mPlayer.currentItem) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotContinueNotification:) name:AVPlayerItemPlaybackStalledNotification object:self.mPlayer.currentItem];
        
        [self.mPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:nil];
        [self.mPlayer.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.mPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];//监听状态。播放还是暂停或者其他
        [self.mPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayer.currentItem];
    }
    
    self.preparePlayTime = CFAbsoluteTimeGetCurrent();
    //    NSLog(@"preparePlayTime = %f",self.preparePlayTime);
    
}

- (void)play{
    
    [self.mPlayer play];
    self.hasPlay = YES;
}

- (void)stop{
    
    [self.mPlayer pause];
    self.preloading = YES;
    self.hasPreloaded = NO;
    self.hasPlay = NO;

//    [self.mPlayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
//    [self.mPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
//    [self.mPlayer removeObserver:self forKeyPath:@"rate" context:nil];
//
//    self.playerItem = nil;
//    self.mPlayer = nil;
//    [self.playerLayer removeFromSuperlayer];
//    self.playerLayer = nil;
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
        NSTimeInterval timeInterval = [self p_availableDuration];// 计算缓冲进度
        NSLog(@"index = %ld timeInterval = %f",(long)self.curIdx,timeInterval);
        CMTime time = self.playerItem.duration;
        CGFloat total = CMTimeGetSeconds(time);
        NSLog(@"总时长:%f",total);
        NSInteger curProgress = timeInterval;
        NSInteger totalTime = total;
        
        if (curProgress >= totalTime/2 && !self.hasPreloaded) {
            
            self.hasPreloaded = YES;

            if (self.loadCompletedBlock) {
                self.loadCompletedBlock();
            }
        }
    }
    
    if ([keyPath isEqualToString:@"rate"])  {//速率为0时候，是暂停或者停止，速率为1，是正在播放
        //速率为0 的时候，播放实际上停止了，此时也停止字幕的播放
        
        if (self.mPlayer.rate == 1) {
//            NSLog(@"播放速度变为1");
        }else if (self.mPlayer.rate == 0) {
//            NSLog(@"播放速度变为0");
        }
        
    }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        NSLog(@"缓冲达到可播放程度了");
        
        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        if (!self.preloading) {
             [self.mPlayer play];
        }
        else{
            [self.mPlayer pause];
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

