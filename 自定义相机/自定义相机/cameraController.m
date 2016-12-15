//
//  cameraController.m
//  自定义相机
//
//  Created by coral_xxd on 16/12/14.
//  Copyright © 2016年 coral_xxd. All rights reserved.
//

#import "cameraController.h"
#import <AVFoundation/AVFoundation.h>

#define MYWIDTH  CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MYHEIGHT  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define WIDTH  MYWIDTH / 375
#define HEIGHT MYHEIGHT / 667

@interface cameraController ()<AVCaptureMetadataOutputObjectsDelegate>
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic,strong)AVCaptureDevice *device ;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic,strong)AVCaptureDeviceInput *input ;
//当启动摄像头开始捕获输入
@property(nonatomic,strong)AVCaptureMetadataOutput *output ;

@property (nonatomic,strong)AVCaptureStillImageOutput *ImageOutPut;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic,strong)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic,strong)UIButton *phoneBtn ;

@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,strong)UIButton *cancelBtn ;

@property(nonatomic,strong)UIButton *sureBtn;

@end

@implementation cameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"拍摄身份证";

    if ([self canOpenCamera]) {
        
        [self createCamera];
        [self bottomView];
    }
    
}


-(void)createCamera{
 
    self.view.backgroundColor = [UIColor blackColor];
   //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
     //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
     //生成会话，用来结合输入输出
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        
    }

    if ([self.session canAddInput:self.input]) {
        
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
  //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    self.previewLayer.frame = CGRectMake(0, 0, MYWIDTH, 450*HEIGHT);

    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.session startRunning];
     //开始启动
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
   
    
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"拍摄身份证"]];
    backImageView.frame = self.previewLayer.frame ;
    [self.view addSubview:backImageView];
    
    UILabel *PromptLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 400*HEIGHT, self.view.frame.size.width, 20)];
    PromptLab.textAlignment = NSTextAlignmentCenter ;
    PromptLab.text = @"保持身份证平稳摆放,四角对齐,点击拍摄";
    PromptLab.textColor = [UIColor whiteColor];
    [self.view addSubview:PromptLab];

    
}


-(void)bottomView{

    self.phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.phoneBtn.frame = CGRectMake(MYWIDTH*1/2.0-30, MYHEIGHT-100*HEIGHT-64, 60, 60);
    [self.phoneBtn setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [self.phoneBtn setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
    [self.phoneBtn addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.phoneBtn];

    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(20*WIDTH, MYHEIGHT-100*HEIGHT-64, 60, 60);
    self.cancelBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn addTarget:self action:@selector(cancelMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitle:@"重拍" forState:UIControlStateNormal];
    self.cancelBtn.layer.masksToBounds = YES ;
    self.cancelBtn.layer.cornerRadius = 30 ;
    self.cancelBtn.hidden = YES ;
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sureBtn.frame = CGRectMake(MYWIDTH-60-20*WIDTH, MYHEIGHT-100*HEIGHT-64, 60, 60);
    self.sureBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.sureBtn];
    [self.sureBtn addTarget:self action:@selector(sureBtnMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.sureBtn.layer.masksToBounds = YES ;
    self.sureBtn.layer.cornerRadius = 30 ;
    self.sureBtn.hidden = YES ;
}

#pragma mark - 截取照片
-(void)shutterCamera{

    AVCaptureConnection *videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    
    if (!videoConnection) {
        
        return ;
    }
    
   [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
       
       if (imageDataSampleBuffer == NULL) {
           
           return  ;
       }
       
       NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
       
       [self.session stopRunning];
       
       self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
       self.imageView.layer.masksToBounds = YES;
       self.imageView.image = [UIImage imageWithData:imageData] ;
       NSLog(@"image size = %@",NSStringFromCGSize(self.imageView.image.size));

   }];
    
    self.cancelBtn.hidden = NO;
    self.sureBtn.hidden = NO ;
}

/**
 *  压缩图片尺寸
 *
 *  @param image   图片
 *  @param newSize 大小
 *
 *  @return 真实图片
 */
- (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)cancelMethod{
    self.cancelBtn.hidden = YES;
    self.sureBtn.hidden = YES ;
    
    [self.imageView removeFromSuperview];
    [self.session startRunning];
}

-(void)sureBtnMethod{

    self.backImage(self.imageView.image);
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(BOOL)canOpenCamera{

    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear|UIImagePickerControllerCameraDeviceFront]) {
        
        return YES ;
    }else{
        
    
        return NO ;
    }


}
#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

-(void)backToFront{

    [self.navigationController popViewControllerAnimated:YES];

}


@end
