//
//  NextViewController.m
//  AOPDemo
//
//  Created by 飞鱼 on 2019/4/15.
//  Copyright © 2019 xxx. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backAction)];
    // Do any additional setup after loading the view.
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
