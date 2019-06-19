//
//  AVSimpleAudioPlayer.m
//  MediaFramework
//
//  Created by Lee on 2019/6/17.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "AVSimpleAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AVSimpleAudioPlayer ()

@property (nonatomic, strong) AVQueuePlayer *queuePlayer;

@end
@implementation AVSimpleAudioPlayer

static AVSimpleAudioPlayer *player;
+ (instancetype)audioPlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[[self class] alloc] init];
    });
    return player;
}
+ (void)releaseAudioPlayer
{
    if (player) {
        [player.queuePlayer removeAllItems];
        player = nil;
    }
}

- (void)addAudioPlayerWithPlayerUrl:(NSString *)url
{
    [_queuePlayer removeAllItems];
    
    
    NSURL *aUrl;
    if ([url stringByAppendingPathExtension:@"bundle"]) {
        aUrl = [NSURL fileURLWithPath:url];
    } else {
        aUrl = [NSURL URLWithString:url];
    }
    
    AVAsset *aset = [AVAsset assetWithURL:aUrl];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:aset];
    
    self.queuePlayer = [AVQueuePlayer playerWithPlayerItem:item];
    
    [self.queuePlayer play];
}

@end
