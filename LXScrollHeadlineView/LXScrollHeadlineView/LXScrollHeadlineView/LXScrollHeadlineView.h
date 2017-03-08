//
//  LXScrollHeadlineView.h
//  LXScrollHeadlineView
//
//  Created by starxin on 17/3/8.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXScrollHeadline;

typedef NS_ENUM(NSUInteger,LXScrollHeadlineType) {
    LXScrollHeadlineTypeAequilate = 0,  //标题等宽,默认情况下是计算所有标题最多字符串的宽度
    LXScrollHeadlineTypeEquidistant     //标题等间距，标题采用根据字符串自适应
};

@interface LXScrollHeadlineView : UIView


/**
 *  @abstract 初始化类似于网易新闻的标题和相关控制器
 *  @param headlines 标题模型数组 默认标题类型是LXHeadlinesTypeAequilate
 *  @param frame 整个框架的frame
 */
+ (instancetype)scrollHeadlineView:(NSArray <LXScrollHeadline *>*)headlines frame:(CGRect)frame;

/*********************以下为属性设置****************************/
/** 标题默认字体大小 默认值为系统14号字 */
@property (nonatomic,strong) UIFont *defaultFont;
/** 标题被选中时字体放大倍数 默认是0.3 */
@property (nonatomic,assign) CGFloat selectedMultiple;
/** 标题默认颜色 默认值为blackColor */
@property (nonatomic,strong) UIColor *defaultColor;
/** 标题被选中的颜色 默认值为redColor */
@property (nonatomic,strong) UIColor *selectedColor;
/** 整个标题的高度 默认为44 */
@property (nonatomic,assign) CGFloat headlinesHeight;
/** 标题之间的水平间距 默认值是6 */
@property (nonatomic,assign) CGFloat betweenMarginX;
/** 初始标题和最后一个标题距离边缘的水平间距 默认是6 */
@property (nonatomic,assign) CGFloat marginX;
/** 点击标题时，字体放大和颜色变化的动画时长 默认是0.3s*/
@property (nonatomic,assign) CGFloat duration;
/** 标题排布方式 默认是LXScrollHeadlineTypeAequilate */
@property (nonatomic,assign) LXScrollHeadlineType headlinesType;


@end
