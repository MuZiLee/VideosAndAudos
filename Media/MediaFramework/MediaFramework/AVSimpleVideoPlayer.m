//
//  AVSimpleVideoPlayer.m
//  MediaFramework
//
//  Created by Lee on 2019/6/17.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "AVSimpleVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AVSimpleVideoPlayer ()

@property (nonatomic, strong) AVPlayerLayer *layer;

@end
@implementation AVSimpleVideoPlayer

static AVSimpleVideoPlayer *vPlayer;
+ (instancetype)videoPlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vPlayer = [[[self class] alloc] init];
    });
    return vPlayer;
}

+ (void)releaseVideoPlayer
{
    if (vPlayer) {
        [(AVQueuePlayer *)vPlayer.layer.player removeAllItems];
        [(AVQueuePlayer *)vPlayer.layer removeAllItems];
        [vPlayer.layer removeAllAnimations];
        [vPlayer.layer removeFromSuperlayer];
        [vPlayer.layer.player removeTimeObserver:vPlayer];
    }
}

- (void)appVideoPlayerWithUrl:(NSString *)url addSupView:(UIView *)aView
{
    [(AVQueuePlayer *)vPlayer removeAllItems];
    
    NSURL *aUrl = [NSURL fileURLWithPath:url];
    if (![url stringByAppendingPathExtension:@"bundle"]) {
        aUrl = [NSURL URLWithString:url];
    }
    
    
    AVAsset *asset = [AVAsset assetWithURL:aUrl];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    AVPlayer *layer = [AVPlayer playerWithPlayerItem:item];
    
    self.layer = [AVPlayerLayer playerLayerWithPlayer:layer];
    self.layer.frame = aView.bounds;
    
    [self.layer player];
}

@end
