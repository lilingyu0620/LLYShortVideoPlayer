//
//  AVAssetResourceLoadingDataRequest+ShortVideoCache.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/26.
//  Copyright © 2019 lly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAssetResourceLoadingDataRequest (ShortVideoCache)

@property (nonatomic, assign) NSInteger respondedSize;

@end

NS_ASSUME_NONNULL_END
