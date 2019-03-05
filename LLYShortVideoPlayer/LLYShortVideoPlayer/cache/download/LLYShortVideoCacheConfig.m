//
//  LLYShortVideoCacheConfig.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoCacheConfig.h"

@implementation LLYShortVideoCacheConfig

+ (instancetype)defaultConfig{
    
    LLYShortVideoCacheConfig *config = [LLYShortVideoCacheConfig new];
    
    config.maxTempCacheSize = 1024*1024*100;//100mb
    config.maxFinalCacheSize = 1024*1024*200;
    config.maxTempCacheTimeInterval = 1*24*60*60;//1day
    config.maxFinalCacheTimeInterval = 2*24*60*60;
    
    return config;
}

@end
