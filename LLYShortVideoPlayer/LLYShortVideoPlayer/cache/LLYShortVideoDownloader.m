//
//  LLYShortVideoDownloader.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/22.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoDownloader.h"

@interface LLYShortVideoDownloader ()

@property (nonatomic, strong) NSOperationQueue *queue;

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
    }
    return self;
    
}

- (void)downloadWithUrl:(NSString *)url
              progressBlock:(LLYShortVideoDownloadProgressBlock)progressBlock
            completionBlock:(LLYShortVideoDownloadCompletionBlock)completionBlock{
    
    LLYShortVideoDownloadOperation *operation = [[LLYShortVideoDownloadOperation alloc]initWithUrl:url progressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        if (progressBlock) {
            progressBlock(receivedSize,expectedSize);
        }
        
    } completionBlock:^(NSError *error) {
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    [self.queue addOperation:operation];
}



@end
