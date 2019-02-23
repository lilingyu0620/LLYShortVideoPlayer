//
//  LLYFileManager.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYFileManager : NSObject

+ (BOOL)createDirectoryAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
