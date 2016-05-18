//
//  YGBanner.m
//  ScrollView循环滚到-2
//
//  Created by wuyiguang on 16/1/8.
//  Copyright (c) 2016年 YG. All rights reserved.
//

#import "YGBanner.h"
#import "UIImageView+WebCache.h"
@interface YGBanner () <UIScrollViewDelegate>

@end

@implementation YGBanner
{
    UIScrollView *_sv;
    UIPageControl *_pgCtrl;
    UIImageView *_leftView; // 左边的图片
    UIImageView *_centerView; // 中间的图片
    UIImageView *_rightView; // 右边的图片;
    NSArray *_imageNames;
    NSInteger _currIndex; // 当前下标
    NSTimer *_timer;
    CGSize _size; // scollView的宽高
}

- (instancetype)initWithFrame:(CGRect)frame imageNames:(NSArray *)names block:(imageHandle)block
{
    if (self = [super initWithFrame:frame]) {
        
        // 记录
        _size = frame.size;
        _imageNames = names;
        _currIndex = 0;
        _block = block;
        
        // 实例化ScrollView
        _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _size.width, _size.height)];
        
        _sv.pagingEnabled = YES;
        
        _sv.bounces = NO;
        
        _sv.showsHorizontalScrollIndicator = NO;
        
        _sv.delegate = self;
        
        // 三屏循环滚到
        _sv.contentSize = CGSizeMake(_size.width * 3, _size.height);
        
        [self addSubview:_sv];
        
        // 添加tap手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle)];
        
        [_sv addGestureRecognizer:tap];
        
        
        // 实例化PageControl
        _pgCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _size.height - 30, _size.width, 30)];
        
        _pgCtrl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        // 点的个数为数组的count
        _pgCtrl.numberOfPages = _imageNames.count;
        
        _pgCtrl.enabled = NO;
        
        [self addSubview:_pgCtrl];
        
        // 实例化三个图片
        [self instanceImageView];
        
        // 开启定时器
        [self startTimer];
        
    }
    return self;
}

// tap手势
- (void)tapHandle
{
    if (self.block) {
        
        self.block(_currIndex);
    }
}

/**
 *  实例化三个图片
 */
- (void)instanceImageView
{
    // 只有三屏
    for (int i = 0; i < 3; i++) {
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_size.width * i, 0, _size.width, _size.height)];
        
        [_sv addSubview:imageV];
        
        // 最后一张图
        if (i == 0) {
            
            [imageV sd_setImageWithURL:[_imageNames lastObject]];
            _leftView = imageV;
            
        } else if (i == 1) {
            
            // 中间的图片，第一张图
            [imageV sd_setImageWithURL:[_imageNames firstObject]];
            _centerView = imageV;
            
        } else {
            
            // 右边的图片，第二张
            [imageV sd_setImageWithURL:_imageNames[1]];
            _rightView = imageV;
        }
    }
    
    // 滚动到中间这张图
    [_sv setContentOffset:CGPointMake(_size.width, 0) animated:NO];
}

/**
 *  开启定时器
 */
- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

/**
 *  自动滚屏
 */
- (void)autoScroll
{
    // 滚动到下一屏
    [_sv setContentOffset:CGPointMake(_size.width * 2, 0) animated:YES];
    
    // 重新设置图片
    [self reloadImageView];
}

/**
 重新设置图片
 */
- (void)reloadImageView
{
    // 获取x的偏移量
    CGFloat offsetX = _sv.contentOffset.x;
    
    // 向左滑动
    if (offsetX > _size.width) {
        
        _currIndex = (_currIndex + 1) % _imageNames.count;
        
    } else if (offsetX < _size.width) {
        // 向右滑动
        
        _currIndex = (_currIndex - 1 + _imageNames.count) % _imageNames.count;
    }
    
    NSInteger leftIndex = (_currIndex - 1 + _imageNames.count) % _imageNames.count;
    NSInteger rightIndex = (_currIndex + 1) % _imageNames.count;
    
    // 重新设置图片
    [_leftView sd_setImageWithURL:_imageNames[leftIndex]];
    [_centerView sd_setImageWithURL:_imageNames[_currIndex]];
    [_rightView sd_setImageWithURL:_imageNames[rightIndex]];
}

- (void)positionView
{
    [self reloadImageView];
    
    _pgCtrl.currentPage = _currIndex;
    
    // 滚动到中间
    [_sv setContentOffset:CGPointMake(_size.width, 0) animated:NO];
}

#pragma mark - UIScrollViewDelegate

// 拖动时，停止减速会被调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self positionView];
    
    [self startTimer];
    

}

// 当设置setContentOffset且为YES时被调用，手势拖动不会调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self positionView];
    

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timer invalidate];
    _timer = nil;
}

@end
