//
//  LLYShortVideoPreloadManager.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/27.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoPreloadManager.h"
#import "LLYCollectionViewCell.h"

@interface LLYShortVideoPreloadManager ()

@property (nonatomic, strong) NSMutableArray *cellArray;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation LLYShortVideoPreloadManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LLYShortVideoPreloadManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[LLYShortVideoPreloadManager alloc] init];
    });
    return instance;
}


- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.lock = [NSLock new];
        self.isLoading = NO;
    }
    return self;
    
}

- (void)addCell:(LLYCollectionViewCell *)cell{
    
    if (NSNotFound == [self.cellArray indexOfObject:cell]) {
        [self.cellArray addObject:cell];
    }
    
    [self preload];
}

- (void)preload{
    
    if (self.cellArray.count <= 0 || self.isLoading) {
        return;
    }
    
    LLYCollectionViewCell *cell = self.cellArray.firstObject;
    cell.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:cell.url]];
    cell.mPlayer = [AVPlayer playerWithPlayerItem:cell.playerItem];
    cell.playerLayer.player = cell.mPlayer;
    [cell.contentView.layer addSublayer:cell.playerLayer];
    
    [cell addObs];
    
    self.isLoading = YES;
    
    __weak __typeof(self)weakSelf = self;
    __weak __typeof(LLYCollectionViewCell *)weakCell = cell;
    cell.loadCompletedBlock = ^{
        
        weakSelf.isLoading = NO;
        [weakSelf.cellArray removeObject:weakCell];
        if (weakSelf.cellArray.count > 0) {
            [weakSelf preload];
        }
    };
    
}

- (NSMutableArray *)cellArray{
    
    if (!_cellArray) {
        _cellArray = [NSMutableArray array];
    }
    return _cellArray;
    
}

@end
