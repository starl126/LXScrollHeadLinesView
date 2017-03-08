//
//  Test0Controller.m
//  LXHeadlinesController
//
//  Created by starxin on 17/3/3.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import "Test0Controller.h"

@interface Test0Controller ()

@end

@implementation Test0Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    int r = arc4random_uniform(255);
    int g = arc4random_uniform(255);
    int b = arc4random_uniform(255);
    self.view.backgroundColor = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}



@end
