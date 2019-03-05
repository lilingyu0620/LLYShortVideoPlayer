//
//  LLYShortVideoCacher.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LLYShortViedoDiskCacher;

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoCacher : NSObject

+ (instancetype)shareInstance;

- (instancetype)initWithDiskCache:(LLYShortViedoDiskCacher *)cache;

- (NSURL *)finalFilePathWithName:(NSURL *)fileUrl;

- (NSString *)createCacheFilePathWithName:(NSURL *)fileUr;

- (void)appendWithData:(NSData *)data fileUrl:(NSURL *)fileUrl;

- (NSData *)cacheDataFromOffset:(NSUInteger)offset length:(NSUInteger)length fileUrl:(NSURL *)fileUrl;

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url;

- (NSInteger)finalCachedSizeWithUrl:(NSURL *)url;

- (NSInteger)tempCachedSizeWithUrl:(NSURL *)url;

- (void)cacheCompletedWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
