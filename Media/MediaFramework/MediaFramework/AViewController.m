//
//  AViewController.m
//  MediaFramework
//
//  Created by Lee on 2019/6/20.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "AViewController.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <GPUImage/GPUImage.h>
#import <Photos/Photos.h>

@interface AViewController ()
{
    AVMutableCompositionTrack *AudioTrack;
    
    
}

@property (nonatomic, strong) AVAssetExportSession *exporter;

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSURL *audioUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"2遇见" ofType:@"mp3"]];
    NSURL *audioUrl2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"胡广生" ofType:@"mp3"]];
    NSURL *videoPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"output115609534271000" ofType:@"mov"]];

    [self addVideos:@[videoPath] audios:@[audioUrl, audioUrl2]];
}

- (void)addVideos:(NSArray <NSURL *>*)videos audios:(NSArray <NSURL *>*)audios
{
    [SVProgressHUD showWithStatus:@"正在合成到系统相册中"];
    NSMutableArray *videosAsset = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *audiosAsset = [NSMutableArray arrayWithCapacity:0];
    
    for (NSURL *videoPath in videos) {
        
        AVAsset *asset = [AVAsset assetWithURL:videoPath];
        [videosAsset addObject:asset];
    }
    
    for (NSURL *audioPath in audios) {
        
        AVAsset *asset = [AVAsset assetWithURL:audioPath];
        [audiosAsset addObject:asset];
    }
    
    // 1 - 创建 AVMutableComposition 对象. 对象将保存AVMutableCompositionTrack实例.
    AVMutableComposition *mix = [[AVMutableComposition alloc] init];
    // 2 - 视频轨道
    AVMutableCompositionTrack *videoTrack = [mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    for (AVAsset *asset in videosAsset) {
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }

    NSMutableArray *audioTrackes = [NSMutableArray arrayWithCapacity:0];
    [audiosAsset enumerateObjectsUsingBlock:^(AVAsset *asset, NSUInteger idx, BOOL *stop) {
        AVMutableCompositionTrack *AudioTrack = [mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:(int32_t)idx];
        [AudioTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        [audioTrackes addObject:AudioTrack];
    }];
    
    // 4 - 获取路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 5 - 创建导出
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:mix presetName:AVAssetExportPresetHighestQuality];
    
    
    //修改背景音乐的音量start
    AVMutableAudioMix *videoAudioMixTools = [AVMutableAudioMix audioMix];
    
    //获取音频轨道
    NSMutableArray *inputParameters = [NSMutableArray arrayWithCapacity:0];
    [audiosAsset enumerateObjectsUsingBlock:^(AVAsset *asset, NSUInteger idx, BOOL *stop) {
        AVMutableAudioMixInputParameters *audioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrackes[idx]];
        [audioParameters setVolumeRampFromStartVolume:1.0 toEndVolume:1.0 timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(kCMTimeZero, asset.duration))];
        
        [audioParameters setTrackID:(int32_t)idx];
        
        [inputParameters addObject:audioParameters];
    }];
    
    videoAudioMixTools.inputParameters = inputParameters;
    
    
    self.exporter.outputURL = url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.audioMix = videoAudioMixTools;
    self.exporter.shouldOptimizeForNetworkUse = YES;
    __weak typeof(self) wSelf = self;
    [self.exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf exportDidFinish:wSelf.exporter];
        });
    }];
}


- (void)exportDidFinish:(AVAssetExportSession *)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            __block PHObjectPlaceholder *placeholder;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path)) {
                NSError *error;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                } error:&error];
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                }
                else{
                    [SVProgressHUD showSuccessWithStatus:@"视频已经保存到相册"];
                }
            }else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"视频保存相册失败，请设置软件读取相册权限", nil)];
            }
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
