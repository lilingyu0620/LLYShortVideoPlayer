//
//  LLYShortVideoPreloadManager.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/27.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LLYCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoPreloadManager : NSObject

+ (instancetype)sharedInstance;

- (void)addCell:(LLYCollectionViewCell *)cell;

- (void)removeCells;

@end

NS_ASSUME_NONNULL_END
