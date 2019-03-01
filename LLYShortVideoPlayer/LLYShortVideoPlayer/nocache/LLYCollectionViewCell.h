//
//  LLYCollectionViewCell.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/20.
//  Copyright © 2019 lly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoLoadCompleted)(void);

@interface LLYCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong,nullable) AVPlayer *mPlayer;
@property (nonatomic, strong,nullable) AVPlayerLayer *playerLayer;
@property (nonatomic, strong,nullable) AVPlayerItem *playerItem;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) BOOL preloading;

//已预加载未播放 不需要重复加载
@property (nonatomic, assign) BOOL hasPlay;
@property (nonatomic, assign) BOOL hasPreloaded;

@property (nonatomic, copy) VideoLoadCompleted loadCompletedBlock;

- (void)stop;
- (void)play;
- (void)configWithUrl:(NSString *)urlStr idx:(NSInteger)idx;

- (void)addObs;

@end

NS_ASSUME_NONNULL_END
