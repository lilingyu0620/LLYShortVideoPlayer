//
//  LLYShortVideoManager.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/25.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoManager : NSObject

+ (instancetype)shareInstance;

- (void)loadVideoWithUrl:(NSURL *)url
               progress:(LLYShortVideoDownloadProgressBlock)progress
             completion:(LLYShortVideoDownloadCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
