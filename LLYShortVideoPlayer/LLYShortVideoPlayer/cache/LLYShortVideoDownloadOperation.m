//
//  LLYShortVideoDownloadOperation.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoDownloadOperation.h"
#import "LLYHttpSessionManager.h"
#import <AFNetworking.h>

@interface LLYShortVideoDownloadOperation ()

@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite) BOOL started;

@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) NSInteger receivedSize;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, copy) LLYShortVideoDownloadProgressBlock progressBlock;
@property (nonatomic, copy) LLYShortVideoDownloadCompletionBlock completeBlock;

@end

@implementation LLYShortVideoDownloadOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                  progressBlock:(LLYShortVideoDownloadProgressBlock)progressBlock
                completionBlock:(LLYShortVideoDownloadCompletionBlock)completionBlock{
    self = [super init];
    if (self) {
        self.request = request;
        self.executing = NO;
        self.finished = NO;
        self.cancelled = NO;
        self.lock = [[NSRecursiveLock alloc]init];
        self.progressBlock = progressBlock;
        self.completeBlock = completionBlock;
    }
    return self;
}

- (void)start{
    
//    [_lock lock];
    
    [[LLYHttpSessionManager shareInstance] setDidReceiveResponseBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        self.expectedSize = response.expectedContentLength;
        self.receivedSize = 0;
        
        [self.lock lock];
        [[LLYShortVideoCacher shareInstance] createCacheFilePathWithName:self.request.URL];
        [self.lock unlock];
    }];
    
    [[LLYHttpSessionManager shareInstance] setDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        self.receivedSize += data.length;
        
        [self.lock lock];
        [[LLYShortVideoCacher shareInstance] appendWithData:data fileUrl:self.request.URL];
        [self.lock unlock];
        
        if (self.progressBlock) {
            self.progressBlock(self.receivedSize, self.expectedSize,data);
        }
    }];
    
    self.task = [[LLYHttpSessionManager shareInstance] requestVIDEOWithRequest:self.request parameters:nil progress:^(NSProgress * _Nullable downloadProgress) {
//        NSLog(@"downloadProgress = %f",downloadProgress.completedUnitCount*1.00000/downloadProgress.totalUnitCount*1.00000);
    } success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSLog(@"success");
        
        //下载完成 将文件保存在final文件夹
        if ([[LLYShortVideoCacher shareInstance] tempCachedSizeWithUrl:self.request.URL] >= self.expectedSize && ![[LLYShortVideoCacher shareInstance] isCacheCompletedWithUrl:self.request.URL]) {
            [[LLYShortVideoCacher shareInstance] cacheCompletedWithUrl:self.request.URL];
        }
        
        if (self.completeBlock) {
            self.completeBlock(nil);
        }
        [self p_finish];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {

        if (self.completeBlock) {
            self.completeBlock(error);
        }
        [self p_finish];

    }];
    
//    [_lock unlock];
}

#pragma mark - Getter/Setter

- (BOOL)isFinished{
    [_lock lock];
    BOOL isfinish = _finished;
    [_lock unlock];
    return isfinish;
}

- (void)setFinished:(BOOL)finished{
    
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
    
}

- (BOOL)isExecuting{
    
    [_lock lock];
    BOOL isExecut = _executing;
    [_lock unlock];
    return isExecut;
    
}

- (void)setExecuting:(BOOL)executing{
    
    [_lock lock];
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
    
}

- (BOOL)isCancelled{
    
    [_lock lock];
    BOOL isCancel = _cancelled;
    [_lock unlock];
    return isCancel;
    
}

- (void)setCancelled:(BOOL)cancelled{
    
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
    
}

- (BOOL)isConcurrent{
    return YES;
}

- (BOOL)isAsynchronous{
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if([key isEqualToString:@"isExecuting"] ||
       [key isEqualToString:@"isFinished"] ||
       [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Private Method

- (void)p_finish{
    self.finished = YES;
    self.executing = NO;
}

- (void)p_cancel{
    
    [_lock lock];
    
    if (![self isCancelled]) {
        
        [super cancel];
        self.cancelled = YES;
        
        if ([self isExecuting]) {
            self.executing = NO;
            [self p_cancelTask];
        }
        
        [self p_finish];
    }
    
    [_lock unlock];
    
}

- (void)p_cancelTask{
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}


@end
