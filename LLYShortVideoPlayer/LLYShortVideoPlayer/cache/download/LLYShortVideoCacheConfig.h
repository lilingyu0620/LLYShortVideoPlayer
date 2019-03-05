//
//  LLYShortVideoCacheConfig.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoCacheConfig : NSObject

@property (nonatomic, assign) NSInteger maxTempCacheSize;
@property (nonatomic, assign) NSInteger maxFinalCacheSize;
@property (nonatomic, assign) NSInteger maxTempCacheTimeInterval;
@property (nonatomic, assign) NSInteger maxFinalCacheTimeInterval;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
