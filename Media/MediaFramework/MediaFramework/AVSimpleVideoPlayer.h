//
//  AVSimpleVideoPlayer.h
//  MediaFramework
//
//  Created by Lee on 2019/6/17.
//  Copyright © 2019 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AVSimpleVideoPlayer : NSObject

+ (instancetype)videoPlayer;
+ (void)releaseVideoPlayer;

- (void)appVideoPlayerWithUrl:(NSString *)url;


- (void)appVideoPlayerWithUrl:(NSString *)url addSupView:(UIView *)aView;

@end
