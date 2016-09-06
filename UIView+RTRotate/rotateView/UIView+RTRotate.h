//
//  UIView+RTRotate.h
//  UIGestureRecognizer
//
//  Created by Xiaojie Feng on 16/6/20.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RTRotateMode) {
    RTRotateModeNormal,
    RTRotateModeGear,
};
typedef NS_ENUM(NSInteger, RTRotateOrientation) {
    RTRotateOrientationUp,     
    RTRotateOrientationLeft,
    RTRotateOrientationDown,
    RTRotateOrientationRight,
};
@protocol RTRotateDelegate <NSObject>
@optional
/**
 *  旋转到90度的整数倍时回调
 *
 *  @param rotateOrientation 旋转方向
 */
- (void)rotateToOrientation:(RTRotateOrientation)rotateOrientation;
/**
 *  旋转即时回调
 *
 *  @param anfle 旋转角度
 */
- (void)rotatingWithAngle:(CGFloat)anfle;
/**
 *  结束旋转时回调
 *
 *  @param anfle 旋转角度
 */
- (void)endRotateWithAngle:(CGFloat)anfle;
/**
 *  预留单击一次的手势，可用于退出视图查看或其他操作
 *
 *  @param recognizer UITapGestureRecognizer
 */
- (void)tapedViewWithGesture:(UITapGestureRecognizer *)recognizer;
/**
 *  view大小开始改变时回调
 */
- (void)viewFrameBeginChangeToRect:(CGRect)rect;

/**
 *  view的大小改变之后回调
 */
- (void)viewFrameChangedToRect:(CGRect)rect;
/**
 *  拖动结束时回调
 */
- (void)endPanWithFrame:(CGRect)rect;
/**
 *  拖动进行时即时回调
 */
- (void)viewOriginChangedToRect:(CGRect)rect;
@end
@interface UIView (RTRotate)
/**
 *  设置view是否能够响应手势
 *
 *  @param enabled YES-响应手势 NO-不响应手势
    PS:每次主动修改view的frame之后都要重新使能手势！！！
 */
- (void)setRotateEnabled:(BOOL)enabled;
/**
 *  设置view是否可以双击放大
 *
 *  @param enabled NO-双击不放大-默认值
                   YES-双击放大－主要用于UIImageView
 */
- (void)setDoubleClickEnlargementEnabled:(BOOL)enabled;
/**
 *  设置view的旋转类型
 *
 *  @param rotateMode RTRotateModeNormal-默认值，普通旋转，结束后复位
                      RTRotateModeGear-旋转结束后选择最接近的水平或者垂直位置复位，主要用于UIImageView
 */
- (void)setRotateMode:(RTRotateMode)rotateMode;
/**
 *  设置view拖动之后是否回到原位
 *
 *  @param enabled NO-回到原位-默认值
                   YES-不回到原位－主要用于视频视图的可拖放,尽量不要与RTRotateModeGear模式一起使用
 */
- (void)setDragEnabled:(BOOL)enabled;
/**
 *  设置是否支持长按显示放大镜效果
 *
 *  @param enabled NO-不支持放大镜-默认值
                   YES-支持放大镜
 */
- (void)setMagnifierEnabled:(BOOL)enabled;
/**
 *  设置是否可以识别PanGesture，图片轮播时与左右翻页冲突，需关闭
 *
 *  @param enabled NO-不识别PanGesture-默认值
                    YES-识别PanGesture
 */
- (void)setPanGestureEnabled:(BOOL)enabled;
/**
 *  设置代理对象
 *
 *  @param value 代理对象
 */
- (void)setRotateDelegate:(id)value;

@end
