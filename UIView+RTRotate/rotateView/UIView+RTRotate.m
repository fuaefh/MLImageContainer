//
//  UIView+RTRotate.m
//  UIGestureRecognizer
//
//  Created by Xiaojie Feng on 16/6/20.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "UIView+RTRotate.h"
#import <objc/runtime.h>
#import "RTGearNumber.h"
#import "RTMagnifierView.h"

#define screenSize   [UIScreen mainScreen].bounds

static CGFloat _rotateAngle;
static CGFloat _animateWithDuration;
static NSInteger _rotateMode;
static CGRect _selfFrame;
static id<RTRotateDelegate> _rotateDelegate;
static CGAffineTransform _transform;
static BOOL _dragEnable;
static BOOL _magnifierEnable;
static BOOL _doubleClickEnlargementEnabled;
static BOOL _panGestureEnabled;

static RTMagnifierView *_magnifierView;

@interface UIView()<UIGestureRecognizerDelegate>
@property (nonatomic,assign) NSNumber *lastGearNumber;
@end
static void *lastGearNumberKey = (void *)@"lastGearNumberKey";
@implementation UIView (RTRotate)
#pragma mark-- associative添加属性
- (NSNumber *)lastGearNumber{
    return objc_getAssociatedObject(self, lastGearNumberKey);
}
- (void)setLastGearNumber:(NSNumber *)value{
    objc_setAssociatedObject(self, lastGearNumberKey, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
#pragma mark-- setup
- (void)setRotateEnabled:(BOOL)enabled{
    _animateWithDuration = 0.2;
    _transform = CGAffineTransformIdentity;
    _selfFrame = self.frame;
    if (enabled)
        [self configGestures];
    else
        [self removeGestures];
}
- (void)configGestures{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc]
                                                    
                                                    initWithTarget:self action:@selector(handleLongPress:)];
    
    longPressReger.minimumPressDuration = 0.5;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleRotate:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePinch:)];
    UITapGestureRecognizer *tapch = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    tapch.numberOfTouchesRequired = 1;
    tapch.numberOfTapsRequired = 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [tap requireGestureRecognizerToFail:tapch];
    
    tapch.delegate = self;
    pan.delegate = self;
    rotate.delegate = self;
    pinch.delegate = self;
    tap.delegate = self;
    longPressReger.delegate = self;
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:rotate];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:tapch];
    [self addGestureRecognizer:tap];
    /**
     *  longPressReger必须添加在最后一个
     */
    [self addGestureRecognizer:longPressReger];
}
- (void)removeGestures{
    NSInteger gestureCount = self.gestureRecognizers.count;
    for (NSInteger i = 0; i < gestureCount; i++) {
        [self removeGestureRecognizer:[self.gestureRecognizers objectAtIndex:0]];
    }
}
- (void)removeGesturesWithoutLongPress{
    NSInteger gestureCount = self.gestureRecognizers.count;
    for (NSInteger i = 0; i < gestureCount; i++) {
        if (![self.gestureRecognizers objectAtIndex:0].state)
            [self removeGestureRecognizer:[self.gestureRecognizers objectAtIndex:0]];
    }
}
#pragma mark-- 事件
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_magnifierEnable) {
        CGPoint point = [gestureRecognizer locationInView:self];
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            [self removeGesturesWithoutLongPress];
            _magnifierView = [[RTMagnifierView alloc] init];
            _magnifierView.viewToMagnify = self;
            [self addSubview:_magnifierView];
            _magnifierView.touchPoint = point;
        }
        else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [_magnifierView removeFromSuperview];
            [self removeGestures];
            [self configGestures];
        }
        else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
            _magnifierView.touchPoint = point;
    }
}
- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    if (recognizer.numberOfTapsRequired == 1) {
        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(tapedViewWithGesture:)])
            [_rotateDelegate tapedViewWithGesture:recognizer];
    }
    else if(recognizer.numberOfTapsRequired == 2){
        if (_doubleClickEnlargementEnabled) {
            if (self.frame.size.width < _selfFrame.size.width*3) {
                CGPoint touchPoint = [recognizer locationInView:self];
                CGRect rect = [[RTGearNumber sharedManager]enlargementWithFrame:self.frame touchPoint:touchPoint scale:3 gearNumber: [self.lastGearNumber integerValue]];
                if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameBeginChangeToRect:)])
                    [_rotateDelegate viewFrameBeginChangeToRect:rect];
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    self.frame = rect;
                } completion:^(BOOL finished) {
                    if (finished) {
                        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                            [_rotateDelegate viewFrameChangedToRect:self.frame];
                    }
                }];
            }
            else{
                if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameBeginChangeToRect:)])
                    [_rotateDelegate viewFrameBeginChangeToRect:_selfFrame];
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    self.frame = _selfFrame;
                } completion:^(BOOL finished) {
                    if (finished) {
                        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                            [_rotateDelegate viewFrameChangedToRect:self.frame];
                    }
                }];
            }
        }
    }
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    if (_panGestureEnabled) {
        CGPoint translation = [recognizer translationInView:self.superview];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewOriginChangedToRect:)])
            [_rotateDelegate viewOriginChangedToRect:self.frame];
        [recognizer setTranslation:CGPointZero inView:self.superview];
        if (recognizer.state == UIGestureRecognizerStateEnded){
            if ((_dragEnable) && (_rotateAngle == 0)){
                // _selfFrame = self.frame;
                if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(endPanWithFrame:)])
                    [_rotateDelegate endPanWithFrame:self.frame];
            }
            else{
                /**
                 *  保证图片放大之后拖动不触发手势结束事件
                 */
                if ((self.frame.size.height <= _selfFrame.size.height) || (self.frame.size.width <= _selfFrame.size.width))
                    [self endGestureRecognizer];
            }
        }
    }
}
- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    _rotateAngle = _rotateAngle + recognizer.rotation;
    recognizer.rotation = 0;
    [self rotatingCallBack];
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(endRotateWithAngle:)])
            [_rotateDelegate endRotateWithAngle:_rotateAngle];
        [self endGestureRecognizer];
    }
}
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    if(recognizer.state == UIGestureRecognizerStateEnded){
        [self endGestureRecognizer];
    }
}
# pragma mark-- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return  YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
#pragma mark-- myFun
- (void)endGestureRecognizer{
    NSInteger gearSkew = [[RTGearNumber sharedManager]refreshSelfFrameWithAngle:_rotateAngle];
    NSInteger gearNumber = [[RTGearNumber sharedManager]gearNumberWithLastGearNumber:[self.lastGearNumber integerValue] gearSkew:gearSkew];
    if (gearSkew == RTRotateOrientationUp || _rotateMode == RTRotateModeNormal) {
        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameBeginChangeToRect:)])
            [_rotateDelegate viewFrameBeginChangeToRect:_selfFrame];
        [UIView animateWithDuration:_animateWithDuration animations:^{
            self.transform = _transform;
            self.frame = _selfFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                    [_rotateDelegate viewFrameChangedToRect:self.frame];
            }
        }];
    }
    else {
        if (_rotateMode == RTRotateModeGear) {
            if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameBeginChangeToRect:)])
                [_rotateDelegate viewFrameBeginChangeToRect:_selfFrame];
            if (gearSkew == RTRotateOrientationRight){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    self.transform = CGAffineTransformRotate(_transform, -M_PI_2);
                    self.frame = _selfFrame;
                    _transform = self.transform;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self rotateToAngleCallBack:gearNumber];
                        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                            [_rotateDelegate viewFrameChangedToRect:self.frame];
                    }
                }];
            }
           else if (gearSkew == RTRotateOrientationDown){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    self.transform = CGAffineTransformRotate(_transform, -M_PI);
                    self.frame = _selfFrame;
                    _transform = self.transform;
                } completion:^(BOOL finished) {
                    if (finished){
                        [self rotateToAngleCallBack:gearNumber];
                        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                            [_rotateDelegate viewFrameChangedToRect:self.frame];
                    }
                }];
            }
           else  if (gearSkew == RTRotateOrientationLeft){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    self.transform = CGAffineTransformRotate(_transform, M_PI_2);
                    self.frame = _selfFrame;
                    _transform = self.transform;
                } completion:^(BOOL finished) {
                    if (finished){
                        [self rotateToAngleCallBack:gearNumber];
                        if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(viewFrameChangedToRect:)])
                            [_rotateDelegate viewFrameChangedToRect:self.frame];
                    }
                }];
            }
        }
    }
    _rotateAngle = 0;
    [self setLastGearNumber:[NSNumber numberWithInteger:gearNumber]];
}
- (void)rotateToAngleCallBack:(RTRotateOrientation)rotateOrientation{
    if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(rotateToOrientation:)])
        [_rotateDelegate rotateToOrientation:rotateOrientation];
}
- (void)rotatingCallBack{
    if (_rotateDelegate && [_rotateDelegate respondsToSelector:@selector(rotatingWithAngle:)])
        [_rotateDelegate rotatingWithAngle:_rotateAngle];
}
- (void)setRotateDelegate:(id)value{
    _rotateDelegate = value;
}
- (void)setRotateMode:(RTRotateMode)rotateMode{
    _rotateMode = rotateMode;
}
-(void)setDragEnabled:(BOOL)enabled{
    _dragEnable = enabled;
}
- (void)setDoubleClickEnlargementEnabled:(BOOL)enabled{
    _doubleClickEnlargementEnabled = enabled;
}
- (void)setMagnifierEnabled:(BOOL)enabled{
    _magnifierEnable = enabled;
}
- (void)setPanGestureEnabled:(BOOL)enabled{
    _panGestureEnabled = enabled;
}
@end
