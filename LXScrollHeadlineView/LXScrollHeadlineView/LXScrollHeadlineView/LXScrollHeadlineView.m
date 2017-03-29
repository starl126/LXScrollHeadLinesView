//
//  LXScrollHeadlineView.m
//  LXScrollHeadlineView
//
//  Created by starxin on 17/3/8.
//  Copyright © 2017年 starxin. All rights reserved.
//

#import "LXScrollHeadlineView.h"
#import "LXScrollHeadline.h"

@interface LXScrollHeadlineView ()<UIScrollViewDelegate>

@property (nonatomic,strong) NSArray <LXScrollHeadline *> *headlines;
@property (nonatomic,strong) NSMutableArray *headlinesWidth;
@property (nonatomic,strong) NSMutableArray <UIButton *>*buttonTitles;
@property (nonatomic,weak) UIScrollView *titleScrollView;
@property (nonatomic,weak) UIScrollView *controllerScrollView;
@property (nonatomic,strong) NSMutableArray <UIViewController *>*controllers;
@property (nonatomic,assign) NSInteger previousPage;
@property (nonatomic,assign) CGFloat factor;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) BOOL clicking;
@property (nonatomic,assign) CGFloat intervalR;
@property (nonatomic,assign) CGFloat intervalG;
@property (nonatomic,assign) CGFloat intervalB;
@property (nonatomic,assign) const CGFloat *defaultComponents;
@property (nonatomic,assign) NSInteger touchesCount;

@end

@implementation LXScrollHeadlineView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _defaultFont = [UIFont systemFontOfSize:14.0];
        _defaultColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        _selectedMultiple = 0.3;
        _selectedColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
        _headlinesHeight =  44.f;
        _betweenMarginX = 6;
        _marginX = 6;
        _previousPoint = CGPointZero;
        _duration = 0.3;
        _headlinesType = LXScrollHeadlineTypeAequilate;
        _titleWidth = 60;
        [self updateRGBComponents];
        [self registerKVO];
    }
    return self;
}
+ (instancetype)scrollHeadlineView:(NSArray <LXScrollHeadline *>*)headlines frame:(CGRect)frame
{
    LXScrollHeadlineView *headlineView = [[LXScrollHeadlineView alloc] initWithFrame:frame];
    headlineView.headlines = headlines;
    [headlineView setupViews];
    return headlineView;
}
- (void)setupViews
{
    UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, _headlinesHeight)];
    titleScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:titleScrollView];
    _titleScrollView = titleScrollView;
    UIScrollView *controllerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headlinesHeight, self.bounds.size.width, self.bounds.size.height - _headlinesHeight)];
    controllerScrollView.delegate = self;
    controllerScrollView.showsHorizontalScrollIndicator = NO;
    controllerScrollView.pagingEnabled = YES;
    [self addSubview:controllerScrollView];
    _controllerScrollView = controllerScrollView;
    
    __weak typeof(self) weakSelf = self;
    [_headlines enumerateObjectsUsingBlock:^(LXScrollHeadline * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf setupTitleButtons:obj];
        [weakSelf setupControllers:obj];
    }];
    [self updateButtonTitlesFrame];
    [self updateControllerView];
    [self updateSelectedTitlePositionX:_buttonTitles.firstObject];
    [self updateSelectedControllerPositionX:_buttonTitles.firstObject.tag];
}
- (void)setupTitleButtons:(LXScrollHeadline *)headline
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:headline.title forState:UIControlStateNormal];
    [btn setTitleColor:_defaultColor forState:UIControlStateNormal];
    btn.titleLabel.font = _defaultFont;
    [btn addTarget:self action:@selector(clickButtonTitle:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = [_headlines indexOfObject:headline];
    [self calculateTitlesButtonWidth:headline];
    [self.buttonTitles addObject:btn];
    [self.titleScrollView addSubview:btn];
}
- (void)setupControllers:(LXScrollHeadline *)headline
{
    Class cls = NSClassFromString(headline.controllerName);
    UIViewController *vc = [[cls alloc] init];
    vc.view.tag = [_headlines indexOfObject:headline];
    [self.controllers addObject:vc];
    [self.controllerScrollView addSubview:vc.view];
}
#pragma mark------------------更新字体颜色的三分量
- (void)updateRGBComponents
{
    const CGFloat *defaultComponents = CGColorGetComponents(_defaultColor.CGColor);
    const CGFloat *selectedComponents = CGColorGetComponents(_selectedColor.CGColor);
    _intervalR = selectedComponents[0] - defaultComponents[0];
    _intervalG = selectedComponents[1] - defaultComponents[1];
    _intervalB = selectedComponents[2] - defaultComponents[2];
    _defaultComponents = defaultComponents;
}
#pragma mark------------------计算字体的宽度
- (void)calculateTitlesButtonWidth:(LXScrollHeadline *)headline
{
    if (_headlinesType != LXScrollHeadlineTypeEqualWidth) {
        NSDictionary *dict = @{NSFontAttributeName:_defaultFont};
        CGRect rect = [headline.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _headlinesHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        headline.width = rect.size.width;
    }else{
        headline.width = _titleWidth;
    }
}
#pragma mark------------------更新控制器的view的frame
- (void)updateControllerView
{
    CGFloat y = 0;
    CGFloat width = self.controllerScrollView.bounds.size.width;
    CGFloat height = self.controllerScrollView.bounds.size.height;
    __block CGFloat x = 0;
    __weak typeof(self) weakSelf = self;
    [_headlines enumerateObjectsUsingBlock:^(LXScrollHeadline * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        x = idx * weakSelf.controllerScrollView.bounds.size.width;
        [weakSelf.controllers[idx] view].frame = CGRectMake(x, y, width, height);
    }];
    _controllerScrollView.contentSize = CGSizeMake(_headlines.count * _controllerScrollView.bounds.size.width, _controllerScrollView.bounds.size.height);
}
#pragma mark------------------点击了标题
- (void)clickButtonTitle:(UIButton *)sender
{
    _previousPage = sender.tag;
    [self updateSelectedTitlePositionX:sender];
    [self updateSelectedControllerPositionX:sender.tag];
    [self updateDisselectedTitlesCondition:sender.tag];
}
#pragma mark------------------更新未被选中的标题按钮状态
- (void)updateDisselectedTitlesCondition:(NSInteger)selected
{
    [_buttonTitles enumerateObjectsUsingBlock:^(UIButton * _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == selected) {
            [UIView animateWithDuration:_duration animations:^{
                btn.transform = CGAffineTransformMakeScale(1 + _selectedMultiple, 1 + _selectedMultiple);
                [btn setTitleColor:_selectedColor forState:UIControlStateNormal];
            }];
        }else{
            [UIView animateWithDuration:_duration animations:^{
                btn.transform = CGAffineTransformIdentity;
                [btn setTitleColor:_defaultColor forState:UIControlStateNormal];
            }];
        }
    }];
}
#pragma mark-------------------点击标题滚动对应控制器
- (void)updateSelectedControllerPositionX:(NSInteger)selected
{
    self.clicking = YES;
    [self.controllerScrollView setContentOffset:CGPointMake(self.controllerScrollView.bounds.size.width * selected, 0) animated:NO];
    self.clicking = NO;
}
#pragma mark-----------------点击标题时更新选中的标题位置到屏幕中央
- (void)updateSelectedTitlePositionX:(UIButton *)sender
{
    //有效的条件
    if (sender.center.x >= self.center.x && (self.titleScrollView.contentSize.width - sender.center.x) >= self.center.x) {
        [self.titleScrollView setContentOffset:CGPointMake(sender.center.x - self.bounds.size.width * 0.5, 0) animated:YES];
    }
    else if (sender.center.x < self.center.x){
        [self.titleScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    else if (sender.center.x > self.center.x && self.titleScrollView.contentSize.width < self.bounds.size.width) {
        [self.titleScrollView setContentOffset:CGPointZero animated:YES];
    }else{
        [self.titleScrollView setContentOffset:CGPointMake(self.titleScrollView.contentSize.width - self.bounds.size.width, 0) animated:YES];
    }
}
#pragma mark------------------更新标题的frame
- (void)updateButtonTitlesFrame
{
    CGFloat y = 0;
    CGFloat height = _headlinesHeight;
    if (_headlinesType == LXScrollHeadlineTypeAequilate) {
        CGFloat maxWidth = [self getMaxWidthForAllHeadlines];
        __block CGFloat x = 0;
        CGFloat width = maxWidth;
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.transform = CGAffineTransformIdentity;
            x = _marginX + idx * (maxWidth + _betweenMarginX);
            obj.frame = CGRectMake(x, y, width, height);
        }];
    }else if (_headlinesType == LXScrollHeadlineTypeEquidistant){
        __block CGFloat x = 0;
        __block CGFloat width = 0;
        __block CGFloat lastMaxX = 0;
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.transform = CGAffineTransformIdentity;
            width = _headlines[idx].width;
            if (0 == idx) {
                x = _marginX;
            }else{
                x = lastMaxX + _betweenMarginX;
            }
            obj.frame = CGRectMake(x, y, width, height);
            lastMaxX = CGRectGetMaxX(obj.frame);
        }];
    }else{
        __block CGFloat x = 0;
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.transform = CGAffineTransformIdentity;
            x = _marginX + idx * (_titleWidth + _betweenMarginX);
            obj.frame = CGRectMake(x, y, _titleWidth, height);
        }];
    }
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(_buttonTitles.lastObject.frame) + _marginX, _headlinesHeight);
    NSLog(@"last=%@,contentsize=%@",NSStringFromCGRect(_buttonTitles.lastObject.frame),NSStringFromCGSize(_titleScrollView.contentSize));
    
}
#pragma mark-------------获取颜色的三基色，适用所有的非RGB的
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1,8,4,rgbColorSpace, kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}
#pragma mark--------------------UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    self.previousPoint = point;
    self.touchesCount ++;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.clicking) {
        return;
    }
    if (self.touchesCount > 1) {
        NSLog(@"flashDraging");
        return;
    }
    CGPoint point = scrollView.contentOffset;
    CGFloat step = self.previousPage * self.controllerScrollView.bounds.size.width - point.x;
    CGFloat factor = ABS(step / self.controllerScrollView.bounds.size.width);
    CGFloat defaultR = _intervalR * factor + _defaultComponents[0];
    CGFloat defaultG = _intervalG * factor + _defaultComponents[1];
    CGFloat defaultB = _intervalB * factor + _defaultComponents[2];
    CGFloat selectedR = _intervalR * (1 - factor) + _defaultComponents[0];
    CGFloat selectedG = _intervalG * (1 - factor) + _defaultComponents[1];
    CGFloat selectedB = _intervalB * (1 - factor) + _defaultComponents[2];
    _factor = factor;
    NSLog(@"---%f----%f----%f----%f",factor,defaultR,defaultG,defaultB);
    if (self.previousPoint.x <= point.x) {//向右滑动
        if (_previousPage < _buttonTitles.count - 1) {
            [self.buttonTitles[_previousPage + 1] setTitleColor:[UIColor colorWithRed:defaultR green:defaultG blue:defaultB alpha:1.0] forState:UIControlStateNormal];
            
            self.buttonTitles[_previousPage + 1].transform = CGAffineTransformMakeScale(1 + factor * _selectedMultiple , 1 + factor * _selectedMultiple);
        }
        [self.buttonTitles[_previousPage] setTitleColor:[UIColor colorWithRed:selectedR green:selectedG blue:selectedB alpha:1.0] forState:UIControlStateNormal];
        self.buttonTitles[_previousPage].transform = CGAffineTransformMakeScale( 1 + _selectedMultiple - factor * _selectedMultiple, 1 + _selectedMultiple - factor * _selectedMultiple);
        
        
    }else{
        if (_previousPage > 0) {
            [self.buttonTitles[_previousPage - 1] setTitleColor:[UIColor colorWithRed:defaultR green:defaultG blue:defaultB alpha:1.0] forState:UIControlStateNormal];
            self.buttonTitles[_previousPage - 1].transform = CGAffineTransformMakeScale( 1 + factor * _selectedMultiple, 1 + factor * _selectedMultiple);
        }
        [self.buttonTitles[_previousPage] setTitleColor:[UIColor colorWithRed:selectedR green:selectedG blue:selectedB alpha:1.0] forState:UIControlStateNormal];
        self.buttonTitles[_previousPage].transform = CGAffineTransformMakeScale(1 + _selectedMultiple - factor * _selectedMultiple, 1 + _selectedMultiple - factor * _selectedMultiple);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    NSInteger page = (point.x + self.controllerScrollView.bounds.size.width * 0.5) / self.controllerScrollView.bounds.size.width;
    if (self.touchesCount > 1) {
        _buttonTitles[page].transform = CGAffineTransformMakeScale(1 + _selectedMultiple, 1 + _selectedMultiple);
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != page) {
                obj.transform = CGAffineTransformIdentity;
                [obj setTitleColor:_defaultColor forState:UIControlStateNormal];
            }
        }];
    }
    [_buttonTitles[page] setTitleColor:_selectedColor forState:UIControlStateNormal];
    self.touchesCount = 0;
    [self updateSelectedTitlePositionX:_buttonTitles[page]];
    _previousPage = page;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    if ([keyPath isEqualToString:@"defaultFont"]) {
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.titleLabel.font = _defaultFont;
            [weakSelf calculateTitlesButtonWidth:_headlines[idx]];
        }];
        [self updateButtonTitlesFrame];
        [self clickButtonTitle:_buttonTitles[_previousPage]];
    }else if ([keyPath isEqualToString:@"defaultColor"] || [keyPath isEqualToString:@"selectedColor"]){
        [_buttonTitles enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitleColor:_defaultColor forState:UIControlStateNormal];
        }];
        [self updateRGBComponents];
        [self updateDisselectedTitlesCondition:_previousPage];
    }else if ([keyPath isEqualToString:@"headlinesHeight"]){
        _titleScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, _headlinesHeight);
        _controllerScrollView.frame = CGRectMake(0, _headlinesHeight, self.bounds.size.width, self.bounds.size.height - _headlinesHeight);
        [self updateButtonTitlesFrame];
        [self updateControllerView];
    }else if ([keyPath isEqualToString:@"betweenMarginX"] || [keyPath isEqualToString:@"marginX"]){
        [self updateButtonTitlesFrame];
    }else if ([keyPath isEqualToString:@"titleWidth"]){
        [self updateButtonTitlesFrame];
    }else if ([keyPath isEqualToString:@"headlinesType"]){
        [self updateButtonTitlesFrame];
    }else{
        
    }
    [self setNeedsLayout];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self clickButtonTitle:_buttonTitles[_previousPage]];
    NSLog(@"%s",__func__);
}
- (CGFloat)getMaxWidthForAllHeadlines
{
    __block CGFloat maxWidth = 0;
    [_headlines enumerateObjectsUsingBlock:^(LXScrollHeadline * _Nonnull headline, NSUInteger idx, BOOL * _Nonnull stop) {
        if (headline.width > maxWidth) {
            maxWidth = headline.width;
        }
    }];
    return maxWidth;
}
- (void)registerKVO
{
    for (NSString *name in [self registerProperties]) {
        [self addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:NULL];
    }
}
- (void)unregisterKVO
{
    for (NSString *name in [self registerProperties]) {
        [self removeObserver:self forKeyPath:name];
    }
}
- (NSArray <NSString *>*)registerProperties
{
    return @[@"defaultFont",@"selectedMultiple",@"defaultColor",@"selectedColor",@"headlinesHeight",@"betweenMarginX",@"marginX",@"duration",@"titleWidth",@"headlinesType"];
}
- (NSMutableArray *)headlinesWidth
{
    if (!_headlinesWidth) {
        _headlinesWidth = [NSMutableArray arrayWithCapacity:_headlines.count];
    }
    return _headlinesWidth;
}
- (NSMutableArray *)buttonTitles
{
    if (!_buttonTitles) {
        _buttonTitles = [NSMutableArray arrayWithCapacity:_headlines.count];
    }
    return _buttonTitles;
}
- (NSMutableArray<UIViewController *> *)controllers
{
    if (!_controllers) {
        _controllers = [NSMutableArray arrayWithCapacity:_headlines.count];
    }
    return _controllers;
}
- (void)dealloc
{
    [self unregisterKVO];
    NSLog(@"dealloc -------%@",NSStringFromClass(self.class));
}

@end
