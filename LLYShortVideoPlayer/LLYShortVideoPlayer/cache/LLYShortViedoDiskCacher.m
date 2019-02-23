//
//  LLYShortViedoDiskCacher.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortViedoDiskCacher.h"
#import "LLYFileManager.h"

static NSString * const kFinalDirectoryName = @"ShortVideoMedia";
static NSString * const kTempDirectoryName = @"ShortVideoTemp";

@interface LLYShortViedoDiskCacher ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *finalPath;
@property (nonatomic, copy) NSString *tempPath;
@property (nonatomic, strong) NSMutableDictionary *fileHandleDic;//对应的每个视频文件的handle

@end

@implementation LLYShortViedoDiskCacher

- (instancetype)initWithPath:(NSString *)path{
    
    self = [super init];
    
    if (self) {
        
        self.path = path;
        self.finalPath = [self.path stringByAppendingPathComponent:kFinalDirectoryName];
        self.tempPath = [self.path stringByAppendingPathComponent:kTempDirectoryName];
        
        //创建目录
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:self.finalPath]) {
            if (![fileManager createDirectoryAtPath:self.finalPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"creat Directory Failed:%@",[error localizedDescription]);
            }
        }
        
        if (![fileManager fileExistsAtPath:self.tempPath]) {
            if (![fileManager createDirectoryAtPath:self.tempPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"creat Directory Failed:%@",[error localizedDescription]);
            }
        }
    }
    
    return self;
}

- (NSString *)createTempFileWithName:(NSString *)fileName{
    
    NSString *filePath = [self.tempPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

- (void)appendData:(NSData *)data tempFileWithName:(NSString *)fileName{
    
    if (!data) {
        return;
    }
    
    if (fileName.length <= 0) {
        return;
    }
    
    NSString *filePath = [self.tempPath stringByAppendingPathComponent:fileName];
    NSFileHandle *fileHandle = self.fileHandleDic[fileName];
    if (!fileHandle) {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        self.fileHandleDic[filePath] = fileHandle;
    }
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    
}

- (NSData *)dataFromOffset:(NSUInteger)offset length:(NSUInteger)length fileName:(NSString *)fileName{
    
    if (fileName.length <= 0) {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finalFilePath = [self.finalPath stringByAppendingPathComponent:fileName];
    NSString *tempFilePath = [self.tempPath stringByAppendingPathComponent:fileName];
    
    NSString *targetFilePath;
    if ([fileManager fileExistsAtPath:finalFilePath]) {
        targetFilePath = finalFilePath;
    }
    else if ([fileManager fileExistsAtPath:tempFilePath]){
        targetFilePath = tempFilePath;
    }
    else{
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:targetFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (!error && data.length > (length+offset)) {
        return [data subdataWithRange:NSMakeRange(offset, length)];
    }
    else{
        return nil;
    }
    
}

@end
