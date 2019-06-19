//
//  ViewController.m
//  MediaFramework
//
//  Created by Lee on 2019/6/16.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "AVSimpleAudioPlayer.h"

@interface ViewController ()


@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *customFilter;

@end

@implementation ViewController
/*
 
 GPUImage的处理环节
 
 source(视频，图片源)->filter(滤镜)->final target(处理后的视频、图片)
 source:
 
 GPUImageVideoCamera 摄像头-用于实时拍摄视频
 GPUImageStillCamera 摄像头-用于实时拍摄照片
 GPUImagePicture 用于处理已经拍摄好的图片
 GPUImageMovie 用于处理已经拍摄好的视频
 -------------------------------------------------------------
 
 filter
 
 GPUImageFilter:就是用来接收源图像，通过自定义的顶点，片元着色器来渲染新的图像，并在绘制完成后通知响应链的下一个对象。
 GPUImageFramebuffer:就是用来管理纹理缓存的格式与读写帧缓存的buffer。
 GPUImage的filter：GPUImageFilter类或者子类，这个类继承自GPUImageOutput,遵循GPUImageInput协议，既可以流进数据，又可以流出GPUImage的final target： GPUImageView,GPUImageMovieWriter最终输入目标，显示图片或者视频。
 -------------------------------------------------------------
 
 

 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *preset = AVCaptureSessionPreset1280x720;
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    
    [self setupVideoCameraWithSessionPreset:preset cameraPosition:position];
    
    
    
    
    
}

#pragma mark - 切换摄像头
- (IBAction)senderSwitchDevicePosition:(UIButton *)sender
{
    NSString *preset = AVCaptureSessionPreset1280x720;
    if ([GPUImageStillCamera isFrontFacingCameraPresent]) {
        [sender setTitle:@"前" forState:(UIControlStateNormal)];
        [self setupVideoCameraWithSessionPreset:preset cameraPosition:AVCaptureDevicePositionFront];
    } else {
        [sender setTitle:@"后" forState:(UIControlStateNormal)];
        [self setupVideoCameraWithSessionPreset:preset cameraPosition:AVCaptureDevicePositionBack];
    }
    
    
    
}

#pragma mark - 开始录制作
- (IBAction)startCameraRecord:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"拍"]) {
        [sender setTitle:@"停" forState:(UIControlStateNormal)];
        
//        [self.videoCamera stopCameraCapture];
    } else {
        [sender setTitle:@"拍" forState:(UIControlStateNormal)];
//        [self.videoCamera startCameraCapture];
        
        NSString *url = [[NSBundle mainBundle] pathForResource:@"2遇见" ofType:@"mp3"];   
        [[AVSimpleAudioPlayer audioPlayer] addAudioPlayerWithPlayerUrl:url];
    }
}


- (void)setupVideoCameraWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)devicePostion
{
//    if ([GPUImageStillCamera isFrontFacingCameraPresent] && devicePostion==AVCaptureDevicePositionFront) {
//        return;
//    }
//    if ([GPUImageStillCamera isBackFacingCameraPresent] && devicePostion==AVCaptureDevicePositionBack) {
//        return;
//    }
    //camera
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:sessionPreset cameraPosition:devicePostion];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft|UIDeviceOrientationLandscapeRight;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;//前摄像头的方向，这个很重要，默认是NO（反转镜像）
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;//后摄像头的方向
    
    
    //filter
    self.customFilter = [[GPUImageFilter alloc] init];
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    // Add the view somewhere so it's visible
    [self.view insertSubview:filteredVideoView atIndex:0];
    [self.videoCamera addTarget:self.customFilter];
    [self.customFilter addTarget:filteredVideoView];
    
    [self.videoCamera startCameraCapture];
}

@end
