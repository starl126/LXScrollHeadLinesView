//
//  LXHeadlinesController.m
//  LXHeadlinesController
//
//  Created by starxin on 17/3/3.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import "LXHeadlinesController.h"
#import "LXHeadline.h"
#import "LXHeadlinesView.h"

@interface LXHeadlinesController ()

@property (nonatomic,strong,readonly) NSArray <LXHeadline *> *headlines;
@property (nonatomic,weak) LXHeadlinesView *headlinesView;

@end

@implementation LXHeadlinesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupViews];
    self.navigationItem.title = @"滚动标题";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
- (void)setupViews
{
    LXHeadline *headline0 = [[LXHeadline alloc] init];
    headline0.title = @"头条";
    headline0.titleID = 2;
    headline0.controllerName = @"Test0Controller";
    LXHeadline *headline1 = [[LXHeadline alloc] init];
    headline1.title = @"要闻";
    headline1.titleID = 1;
    headline1.controllerName = @"Test1Controller";
    LXHeadline *headline2 = [[LXHeadline alloc] init];
    headline2.title = @"娱乐";
    headline2.titleID = 10;
    headline2.controllerName = @"Test2Controller";
    LXHeadline *headline3 = [[LXHeadline alloc] init];
    headline3.title = @"体育";
    headline3.titleID = 21;
    headline3.controllerName = @"Test3Controller";
    LXHeadline *headline4 = [[LXHeadline alloc] init];
    headline4.title = @"电影";
    headline4.titleID = 9;
    headline4.controllerName = @"Test4Controller";
    LXHeadline *headline5 = [[LXHeadline alloc] init];
    headline5.title = @"社会";
    headline5.titleID = 7;
    headline5.controllerName = @"Test5Controller";
    LXHeadline *headline6 = [[LXHeadline alloc] init];
    headline6.title = @"网易号";
    headline6.titleID = 56;
    headline6.controllerName = @"Test6Controller";
    LXHeadline *headline7 = [[LXHeadline alloc] init];
    headline7.title = @"漫画";
    headline7.titleID = 33;
    headline7.controllerName = @"Test7Controller";
    NSArray <LXHeadline *>*array = @[headline0,headline1,headline2,headline3,headline4,headline5,headline6,headline7];
    LXHeadlinesView *headlinesView = [LXHeadlinesView headlinesView:array frame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    headlinesView.betweenMarginX = 20;
    [self.view addSubview:headlinesView];
    _headlinesView = headlinesView;
    [headlinesView setNeedsLayout];
}
- (void)clickRightButton
{
    _headlinesView.defaultFont = [UIFont systemFontOfSize:18];
    _headlinesView.selectedMultiple = 0.4;
    _headlinesView.defaultColor = [UIColor blueColor];
    _headlinesView.selectedColor = [UIColor darkTextColor];
    _headlinesView.headlinesType = LXHeadlinesTypeEquidistant;
    _headlinesView.headlinesHeight = 66;
    _headlinesView.betweenMarginX = 10;
    _headlinesView.marginX = 10;
    _headlinesView.duration = 0.5;
}

@end
