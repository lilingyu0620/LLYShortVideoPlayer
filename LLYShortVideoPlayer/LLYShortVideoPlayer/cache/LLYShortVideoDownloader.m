//
//  LLYShortVideoDownloader.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoDownloader.h"
#import "LLYShortVideoCacher.h"

@interface LLYShortVideoDownloader ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *operationDic;

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
        self.operationDic = [NSMutableDictionary dictionary];
    }
    return self;
    
}

- (void)downloadWithUrl:(NSURL *)url
              progressBlock:(LLYShortVideoDownloadProgressBlock)progressBlock
            completionBlock:(LLYShortVideoDownloadCompletionBlock)completionBlock{
    
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
        [[LLYShortVideoCacher shareInstance] appendWithData:data fileUrl:request.URL];
        
        if (progressBlock) {
            progressBlock(receivedSize,expectedSize,data);
        }
    } completionBlock:^(NSError *error) {
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    [self.queue addOperation:operation];    
}

- (void)cancelDownloadOperationWithUrl:(NSURL *)url{
    
    if (!url) {
        return;
    }
    
    LLYShortVideoDownloadOperation *operation = self.operationDic[url];
    if (operation) {
        [operation cancel];
        [self.operationDic removeObjectForKey:url];
    }
    
}


@end
