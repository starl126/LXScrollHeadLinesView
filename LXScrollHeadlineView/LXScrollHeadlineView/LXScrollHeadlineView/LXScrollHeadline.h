//
//  LXScrollHeadline.h
//  LXScrollHeadlineView
//
//  Created by starxin on 17/3/8.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXScrollHeadline : NSObject

/** 标题的名称 */
@property (nonatomic,copy) NSString *title;
/** 每个标题对应的id */
@property (nonatomic,assign) NSInteger titleID;
/** 每个标题对应的控制器名称 */
@property (nonatomic,copy) NSString *controllerName;
/** 每个标题的额外信息，供扩展用 */
@property (nonatomic,strong) NSDictionary *reference;
/** 根据标题类型、字体大小、标题内容计算的宽度，不需要用户传入，是内部计算所得 */
@property (nonatomic,assign) CGFloat width;

@end
