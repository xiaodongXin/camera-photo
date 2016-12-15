//
//  ViewController.m
//  自定义相机
//
//  Created by coral_xxd on 16/12/13.
//  Copyright © 2016年 coral_xxd. All rights reserved.
//

#import "ViewController.h"
#import "cameraController.h"

@interface ViewController ()


@property (strong, nonatomic) IBOutlet UIImageView *imageView;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor cyanColor];

    

}



- (IBAction)paiZhao:(id)sender {
    
    cameraController *cameraVC = [[cameraController alloc] init];
    
    [cameraVC setBackImage:^(UIImage *image) {
       
        self.imageView.image = image ;
        
    }];
    
    [self.navigationController pushViewController:cameraVC animated:YES];
    
}





@end
