//
//  cameraController.h
//  自定义相机
//
//  Created by coral_xxd on 16/12/14.
//  Copyright © 2016年 coral_xxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cameraController : UIViewController


@property(nonatomic,strong)void (^backImage)(UIImage *image);



@end
