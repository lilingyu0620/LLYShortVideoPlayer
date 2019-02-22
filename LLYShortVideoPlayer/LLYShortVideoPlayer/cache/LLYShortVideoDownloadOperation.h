//
//  LLYShortVideoDownloadOperation.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LLYShortVideoDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^LLYShortVideoDownloadCompletionBlock)(NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoDownloadOperation : NSOperation

- (instancetype)initWithUrl:(NSString *)urlStr
              progressBlock:(LLYShortVideoDownloadProgressBlock)progressBlock
            completionBlock:(LLYShortVideoDownloadCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
