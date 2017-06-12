//
//  ShowImageViewController.m
//  Demo0819
//
//  Created by Chris on 15/8/19.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "ShowImageViewController.h"
#import "ShowImageView.h"

@interface ShowImageViewController ()

@end

@implementation ShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ShowImageView *showImageView = [[ShowImageView alloc]initWithFrame:self.view.bounds byClickTag:self.clickTag appendArray:self.imageViews];
    [self.view addSubview:showImageView];
    __weak ShowImageViewController *weak_self =self;
    showImageView.removeImg = ^(){
        weak_self.navigationController.navigationBarHidden = NO;
        [weak_self.navigationController popViewControllerAnimated:YES];
    };
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
