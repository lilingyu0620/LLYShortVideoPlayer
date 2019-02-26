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

@interface LLYShortVideoManager ()

@property (nonatomic, strong) NSMutableArray *preloadArray;

@end

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

- (void)preloadVideoWithArray:(NSArray<NSURL *> *)urlArray{
    
    self.preloadArray = [NSMutableArray arrayWithArray:urlArray];
    
    [self startPreload];
    
}

- (void)startPreload{
    
    if (self.preloadArray.count <= 0) {
        return;
    }
    
    NSURL *url = self.preloadArray.firstObject;
    [[LLYShortVideoDownloader shareInstance] downloadWithUrl:url progressBlock:nil completionBlock:^(NSError *error) {
        if (!error) {
            
            [self.preloadArray removeObject:url];
            
            [self startPreload];
        }
    }];
}

- (NSData *)cacheDataFromOffset:(NSUInteger)offset
                         length:(NSUInteger)length
                        withUrl:(NSURL *)url{
    return [[LLYShortVideoCacher shareInstance] cacheDataFromOffset:offset length:length fileUrl:url];
}

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url{
    return [[LLYShortVideoCacher shareInstance] isCacheCompletedWithUrl:url];
}

- (NSURL *)finalFilePathWithName:(NSURL *)fileUrl{
    return [[LLYShortVideoCacher shareInstance] finalFilePathWithName:fileUrl];
}

@end
