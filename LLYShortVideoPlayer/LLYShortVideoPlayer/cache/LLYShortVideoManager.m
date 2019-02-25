//
//  LLYShortVideoManager.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/25.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoManager.h"
#import "LLYShortVideoDownloader.h"
#import <AFNetworking.h>

@implementation LLYShortVideoManager

+ (instancetype)shareInstance{
    
    static LLYShortVideoManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[LLYShortVideoManager alloc]init];
    });
    return _manager;
    
}

- (void)loadVideoWithUrl:(NSURL *)url
               progress:(LLYShortVideoDownloadProgressBlock)progress
             completion:(LLYShortVideoDownloadCompletionBlock)completion{
    
    [[LLYShortVideoDownloader shareInstance] downloadWithUrl:url progressBlock:progress completionBlock:^(NSError *error) {
        completion(error);
    }];
    
}

@end
