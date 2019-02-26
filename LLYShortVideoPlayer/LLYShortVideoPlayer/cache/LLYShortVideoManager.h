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

- (void)preloadVideoWithArray:(NSArray<NSURL *> *)urlArray;

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url;

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url;

- (NSURL *)finalFilePathWithName:(NSURL *)fileUrl;

@end

NS_ASSUME_NONNULL_END
