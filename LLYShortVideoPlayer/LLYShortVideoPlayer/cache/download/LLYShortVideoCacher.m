//
//  LLYShortVideoCacher.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoCacher.h"
#import "LLYShortViedoDiskCacher.h"
#import <CommonCrypto/CommonDigest.h>

@interface LLYShortVideoCacher ()

@property (nonatomic, strong) LLYShortViedoDiskCacher *diskCache;

@end

@implementation LLYShortVideoCacher

+ (instancetype)shareInstance{
    static LLYShortVideoCacher *_cacher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"com.163.open"];
        LLYShortViedoDiskCacher *diskCache = [[LLYShortViedoDiskCacher alloc]initWithPath:cachePath];
        _cacher = [[LLYShortVideoCacher alloc]initWithDiskCache:diskCache];
    });
    return _cacher;
}

- (instancetype)initWithDiskCache:(LLYShortViedoDiskCacher *)cache{
    
    self = [super init];
    if (self) {
        self.diskCache = cache;
    }
    return self;
    
}

- (NSString *)createCacheFilePathWithName:(NSURL *)fileUrl{
    
    return [self.diskCache createTempFileWithName:[self fileNameWithUrl:fileUrl]];
    
}

- (void)appendWithData:(NSData *)data fileUrl:(NSURL *)fileUrl{
    
    [self.diskCache appendData:data tempFileWithName:[self fileNameWithUrl:fileUrl]];
}

- (NSData *)cacheDataFromOffset:(NSUInteger)offset length:(NSUInteger)length fileUrl:(NSURL *)fileUrl{
    return [self.diskCache dataFromOffset:offset length:length fileName:[self fileNameWithUrl:fileUrl]];
}

- (BOOL)isCacheCompletedWithUrl:(NSURL *)url{
    
    NSString *fileName = [self fileNameWithUrl:url];
    return [self.diskCache fileExistAtFinalWithName:fileName];
}

- (NSInteger)finalCachedSizeWithUrl:(NSURL *)url{
    
    NSString *fileName = [self fileNameWithUrl:url];
    return [self.diskCache finalCachedSizeWithName:fileName];
}

- (NSInteger)tempCachedSizeWithUrl:(NSURL *)url{
    
    NSString *fileName = [self fileNameWithUrl:url];
    return [self.diskCache tempCachedSizeWithName:fileName];
    
}

- (void)cacheCompletedWithUrl:(NSURL *)url{
    
    NSString *fileName = [self fileNameWithUrl:url];
    [self.diskCache moveTempFileToFinalWithName:fileName];
    
}

- (NSURL *)finalFilePathWithName:(NSURL *)fileUrl{
    
    NSString *filePath = [self.diskCache finalFilePathWithName:[self fileNameWithUrl:fileUrl]];
    return [NSURL fileURLWithPath:filePath];
    
}

#pragma mark - private

- (NSString *)fileNameWithUrl:(NSURL *)fileUrl {
//    NSString *fileName = [_urlFileNameCache objectForKey:url];
    NSString *fileName;
    if(!fileName) {
        fileName = [NSString stringWithFormat:@"%@.%@", [self md5:fileUrl.absoluteString], fileUrl.pathExtension];
//        [_urlFileNameCache setObject:fileName forKey:url];
    }
    return fileName;
}

- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
