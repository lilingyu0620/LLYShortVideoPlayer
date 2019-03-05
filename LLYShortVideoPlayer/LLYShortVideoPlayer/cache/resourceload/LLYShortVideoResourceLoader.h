//
//  LLYShortVideoResourceLoader.h
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/21.
//  Copyright © 2019 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLYShortVideoResourceLoader : NSObject

@property (nonatomic, copy) NSString *url;

- (AVPlayerItem *)playerItemWithUrl:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
