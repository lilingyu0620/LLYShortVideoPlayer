//
//  LLYFileManager.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYFileManager.h"

@implementation LLYFileManager

+ (BOOL)createDirectoryAtPath:(NSString *)path{
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

@end
