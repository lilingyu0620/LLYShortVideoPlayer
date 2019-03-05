//
//  AVAssetResourceLoadingDataRequest+ShortVideoCache.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/26.
//  Copyright © 2019 lly. All rights reserved.
//

#import "AVAssetResourceLoadingDataRequest+ShortVideoCache.h"
#import <objc/runtime.h>

static NSString * const kRespondedSizeKey = @"RespondedSizeKey";

@implementation AVAssetResourceLoadingDataRequest (ShortVideoCache)

- (void)setRespondedSize:(NSInteger)respondedSize{
    
    objc_setAssociatedObject(self, &kRespondedSizeKey, @(respondedSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)respondedSize{
    NSNumber *size = objc_getAssociatedObject(self, &kRespondedSizeKey);
    return [size integerValue];
}

@end
