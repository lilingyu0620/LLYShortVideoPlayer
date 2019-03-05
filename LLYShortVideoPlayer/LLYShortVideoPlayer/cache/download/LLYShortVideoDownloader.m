//
//  LLYShortVideoDownloader.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoDownloader.h"
#import "LLYShortVideoCacher.h"

#define Lock() dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER)
#define UnLock() dispatch_semaphore_signal(self.lock)

@interface LLYShortVideoDownloader ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *operationDic;

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation LLYShortVideoDownloader

+ (instancetype)shareInstance{
    
    static LLYShortVideoDownloader *_downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloader = [[LLYShortVideoDownloader alloc]init];
    });
    return _downloader;
    
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc]init];
        self.queue.maxConcurrentOperationCount = 1;
        self.operationDic = [NSMutableDictionary dictionary];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
    
}

- (void)downloadWithUrl:(NSURL *)url
              progressBlock:(nullable LLYShortVideoDownloadProgressBlock)progressBlock
            completionBlock:(nullable LLYShortVideoDownloadCompletionBlock)completionBlock{
    
    //已缓存
    if ([[LLYShortVideoCacher shareInstance] isCacheCompletedWithUrl:url]) {
        NSInteger fileSize = [[LLYShortVideoCacher shareInstance] finalCachedSizeWithUrl:url];
        if (progressBlock) {
            progressBlock(fileSize,fileSize,nil);
        }
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    //如果正在下载先取消
    [self cancelDownloadOperationWithUrl:url];
    
    NSInteger tempSize = [[LLYShortVideoCacher shareInstance] tempCachedSizeWithUrl:url];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url.absoluteString parameters:nil error:nil];
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-", (long)tempSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    request.HTTPShouldHandleCookies = NO;
    request.HTTPShouldUsePipelining = YES;
    
    LLYShortVideoDownloadOperation *operation = [[LLYShortVideoDownloadOperation alloc]initWithRequest:request progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {        
        if (progressBlock) {
            progressBlock(receivedSize+tempSize,expectedSize,data);
        }
    } completionBlock:^(NSError *error) {
        
        Lock();
        [self.operationDic removeObjectForKey:url];
        UnLock();
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    
    Lock();
    self.operationDic[url] = operation;
    UnLock();
    
    [self.queue addOperation:operation];    
}

- (void)cancelDownloadOperationWithUrl:(NSURL *)url{
    
    if (!url) {
        return;
    }
    
    Lock();
    LLYShortVideoDownloadOperation *operation = self.operationDic[url];
    if (operation) {
        [operation cancel];
        [self.operationDic removeObjectForKey:url];
    }
    UnLock();
    
}


@end
