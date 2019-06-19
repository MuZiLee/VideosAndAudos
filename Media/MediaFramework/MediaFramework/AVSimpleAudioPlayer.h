//
//  AVSimpleAudioPlayer.h
//  MediaFramework
//
//  Created by Lee on 2019/6/17.
//  Copyright © 2019 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AVSimpleAudioPlayer : NSObject

+ (instancetype)audioPlayer;
+ (void)releaseAudioPlayer;


- (void)addAudioPlayerWithPlayerUrl:(NSString *)url;

@end
