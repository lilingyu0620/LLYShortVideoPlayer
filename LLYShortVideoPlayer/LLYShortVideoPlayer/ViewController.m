//
//  ViewController.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/20.
//  Copyright © 2019 lly. All rights reserved.
//

#import "ViewController.h"
#import "LLYShortVideoNoCacheViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)noCacheBtnClicked:(id)sender {
    
    LLYShortVideoNoCacheViewController *vc = [[LLYShortVideoNoCacheViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (IBAction)cacheBtnClicked:(id)sender {
}

@end
