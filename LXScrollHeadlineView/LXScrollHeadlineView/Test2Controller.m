//
//  Test2Controller.m
//  LXHeadlinesController
//
//  Created by starxin on 17/3/3.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import "Test2Controller.h"

@interface Test2Controller ()

@end

@implementation Test2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    int r = arc4random_uniform(255);
    int g = arc4random_uniform(255);
    int b = arc4random_uniform(255);;
    self.view.backgroundColor = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
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
