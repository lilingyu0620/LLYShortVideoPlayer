//
//  LLYShortViedoDiskCacher.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/23.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortViedoDiskCacher : NSObject

- (instancetype)initWithPath:(NSString *)path;

- (NSString *)createTempFileWithName:(NSString *)fileName;

- (void)appendData:(NSData *)data tempFileWithName:(NSString *)fileName;

- (NSData *)dataFromOffset:(NSUInteger)offset length:(NSUInteger)length fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
