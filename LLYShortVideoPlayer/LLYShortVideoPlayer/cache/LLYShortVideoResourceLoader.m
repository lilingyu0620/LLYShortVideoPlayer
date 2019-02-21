//
//  LLYShortVideoResourceLoader.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/21.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoResourceLoader.h"
#import <AFNetworking.h>
#import "LLYHttpSessionManager.h"

@interface LLYShortVideoResourceLoader ()<AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) NSInteger receivedSize;

@property (nonatomic, strong) NSMutableData *tmpData;
@property (nonatomic, assign) NSInteger respondedSize;

@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *loadingRequestArray;

@end

@implementation LLYShortVideoResourceLoader

- (AVPlayerItem *)playerItemWithUrl:(NSString *)urlStr{
    
//    不过需要清楚一点，当提供的URL协议是AVURLAsset能识别处理的时候如(https://xxx.mp4)，该资源加载代理对象是不会收到来自AVURLAsset的数据加载请求的；
//    然而如果我们把URL改成如（sevenuncle://xxx.mp4）的时候，由于AVURLAsset无法识别出该协议，就会转向资源加载代理对象询问数据如何加载,此时就会调用AVAssetResourceLoaderDelegate 协议里的下述方法：
    
    self.url = urlStr;
    self.tmpData = [NSMutableData data];
    self.loadingRequestArray = [NSMutableArray array];
    
    [self p_startLoading];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self unRecognizerUrl] options:nil];
    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    return item;
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (resourceLoader && loadingRequest) {
        [self.loadingRequestArray addObject:loadingRequest];
        [self p_handleLoadingRequests];
    }
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (!loadingRequest.isFinished) {
    };
}

#pragma mark - Private Method

- (NSURL *)unRecognizerUrl {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:@"www.open.163.top"] resolvingAgainstBaseURL:NO];
    components.scheme = @"opencourse";
    return [components URL];
}

- (void)p_startLoading{
    
    [[LLYHttpSessionManager shareInstance] setDidReceiveResponseBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        self.expectedSize = response.expectedContentLength;
        self.receivedSize = 0;
        self.respondedSize = 0;
    }];
    
    [[LLYHttpSessionManager shareInstance] setDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        self.receivedSize += data.length;
        [self.tmpData appendData:data];
        
        [self p_handleLoadingRequests];

    }];
    
    [[LLYHttpSessionManager shareInstance] requestVIDEOWithMethod:LLYHttpMethod_GET urlString:self.url parameters:nil progress:^(NSProgress * _Nullable downloadProgress) {
        NSLog(@"downloadProgress = %f",downloadProgress.completedUnitCount*1.00000/downloadProgress.totalUnitCount*1.00000);
    } success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSLog(@"success");
        
        [self p_handleLoadingRequests];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
    }];
    
}

- (void)p_handleLoadingRequests{
    
    NSMutableArray *finishedRequestArray = [NSMutableArray array];
    [self.loadingRequestArray enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self p_handleContentInformationRequest:obj];
        if ([self p_respondWithDataForRequest:obj]) {
            [finishedRequestArray addObject:obj];
            [obj finishLoading];
        }
    }];
    
    if (finishedRequestArray.count > 0) {
        [self.loadingRequestArray removeObjectsInArray:finishedRequestArray];
    }
    
}

- (void)p_handleContentInformationRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    AVAssetResourceLoadingContentInformationRequest *contentInfomationRequest = loadingRequest.contentInformationRequest;
    if (contentInfomationRequest && !contentInfomationRequest.contentType && self.expectedSize > 0) {
        NSString *fileExtension = [self.url pathExtension];
        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        NSString *contentTypeS = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
        if (!contentTypeS) {
            contentTypeS = @"application/octet-stream";
        }
        NSString *mimetype = contentTypeS;
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimetype), NULL);
        contentInfomationRequest.byteRangeAccessSupported = YES;
        contentInfomationRequest.contentType = CFBridgingRelease(contentType);
        contentInfomationRequest.contentLength = self.expectedSize;
    }
}

- (BOOL)p_respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    
    NSLog(@"requestedLength = %ld",dataRequest.requestedLength);
    
    NSInteger startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    startOffset = MAX(0, startOffset);
    
    if (startOffset > self.receivedSize) {
        return NO;
    }
    
    NSInteger canPlaySize = self.receivedSize - startOffset;
    canPlaySize = MAX(0, canPlaySize);
    
    NSInteger realPlaySize = MIN(dataRequest.requestedLength, canPlaySize);
    
    NSData *playData = [NSData data];
    if (realPlaySize > 2){
        playData = [self.tmpData subdataWithRange:NSMakeRange(startOffset, canPlaySize)];
    }
    
    if (playData) {
        [dataRequest respondWithData:playData];
    }
    
    self.respondedSize += realPlaySize;
    
    if (self.respondedSize >= dataRequest.requestedLength) {
        return YES;
    }
    else{
        return NO;
    }
        
}



@end