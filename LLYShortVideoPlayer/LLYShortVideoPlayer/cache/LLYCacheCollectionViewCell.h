//
//  LLYCacheCollectionViewCell.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/21.
//  Copyright © 2019 lly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYCacheCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger curIdx;

- (void)playWithUrl:(NSString *)urlStr idx:(NSInteger)idx;
- (void)stopWithUrl:(NSString *)urlStr idx:(NSInteger)idx;

- (void)play;

@end

NS_ASSUME_NONNULL_END
