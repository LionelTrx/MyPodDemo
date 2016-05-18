//
//  YGBanner.h
//  ScrollView循环滚到-2
//
//  Created by wuyiguang on 16/1/8.
//  Copyright (c) 2016年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^imageHandle)(NSInteger index);

@interface YGBanner : UIView

@property (nonatomic, copy) imageHandle block;

- (instancetype)initWithFrame:(CGRect)frame imageNames:(NSArray *)names block:(imageHandle)block;

@end
