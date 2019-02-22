//
//  LLYShortVideoDownloader.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLYShortVideoDownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoDownloader : NSObject

+ (instancetype)shareInstance;

- (void)downloadWithUrl:(NSString *)url
          progressBlock:(LLYShortVideoDownloadProgressBlock)progressBlock
        completionBlock:(LLYShortVideoDownloadCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
