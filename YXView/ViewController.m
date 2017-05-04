//
//  ViewController.m
//  YXView
//
//  Created by enghou on 17/5/3.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "ViewController.h"
#import "YXView.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YXView *view  = [[YXView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
