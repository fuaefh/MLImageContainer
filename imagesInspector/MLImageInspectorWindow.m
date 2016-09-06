//
//  MLImageInspectorWindow.m
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "MLImageInspectorWindow.h"
#import "MLImagesInspector.h"
#import "UIImageView+WebCache.h"
#import "UIView+RTRotate.h"

#define screenSize   [UIScreen mainScreen].bounds
@interface MLImageInspectorWindow ()<RTRotateDelegate>
{
    NSArray *_imagesURL;
    NSArray *_beginRectsData;
    NSString *_holderImage;
    NSInteger _touchItemNumber;
    UILabel *pageLabel;
    UIViewController *_rootVc;
    MLImagesInspector *_ScrollView;
    CGFloat _animateWithDuration;
    UIImageView *_currentImageView;
    BOOL _currentImageViewIsRotating;
    BOOL _allowRecover;
    uint32_t _currentImageNumber;
    CGFloat _defaultY;
    /**
     *  判断达到一定速度翻页
     */
    CGFloat _lastX;
    CGFloat _lastY;
    CGFloat _xVelocity;
    CGFloat _dY;
}
@end
@implementation MLImageInspectorWindow
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>init<<<<<<<<<<<<<<<<<<<<
-(id)initWithFrame:(CGRect)frame imagesURL:(NSArray *)urlArray baginRectsData:(NSArray *)rectArray placeHolder:(NSString *)holderImage touchItemNumber:(uint32_t)itemNumber{
    if (self = [super initWithFrame:frame]) {
        _imagesURL = urlArray;
        _beginRectsData = rectArray;
        _holderImage = holderImage;
        _animateWithDuration = 0.2;
        _currentImageNumber = itemNumber - 1;
        _defaultY = 0;
        _touchItemNumber = itemNumber;
        _currentImageViewIsRotating = NO;
        _allowRecover = YES;
        [self setRootViewController];
        [self setViews];
    }
    return self;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>setRootViewController<<<<<<<<<<<<<<<<<<<<
- (void)setRootViewController{
    self.windowLevel = UIWindowLevelAlert;
    _rootVc = [[UIViewController alloc]init];
    self.rootViewController = _rootVc;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>setViews<<<<<<<<<<<<<<<<<<<<
- (void)setViews{
    NSValue *rectValue = [_beginRectsData objectAtIndex:_currentImageNumber];
    CGRect rect = rectValue.CGRectValue;
    _currentImageView = [[UIImageView alloc]initWithFrame:screenSize];
    [_currentImageView sd_setImageWithURL:[self getImageUrlWithString:[_imagesURL objectAtIndex:_currentImageNumber]] placeholderImage:[UIImage imageNamed:_holderImage]];
    _currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    _currentImageView.backgroundColor = [UIColor blackColor];
    [_rootVc.view addSubview:_currentImageView];
    [self configView];
    _currentImageView.tag = 1;
    _currentImageView.frame = rect;
    [UIView animateWithDuration:0.3 animations:^{
        _currentImageView.frame = screenSize;
    } completion:^(BOOL finished) {
        [self setScrollView];
        pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - 50, self.frame.size.height-50, 100, 20)];
        NSString *labelText = [NSString stringWithFormat:@"%d/%d",_currentImageNumber+1,(uint32_t)_imagesURL.count];
        pageLabel.text = labelText;
        pageLabel.backgroundColor = [UIColor clearColor];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.textColor = [UIColor whiteColor];
        [_rootVc.view addSubview:pageLabel];
        [_rootVc.view bringSubviewToFront:_currentImageView];
        [_rootVc.view bringSubviewToFront:pageLabel];
    }];
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>setScrollView<<<<<<<<<<<<<<<<<<<<
- (void)setScrollView{
    _ScrollView = [[MLImagesInspector alloc]initWithFrame:screenSize imagesURL:_imagesURL placeHolder:_holderImage];
    _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width * _currentImageNumber, _ScrollView.contentOffset.y);
    _ScrollView.backgroundColor = [UIColor blackColor];
    [_ScrollView setBlackMaskToImageNumber:_currentImageNumber];
    [_rootVc.view addSubview:_ScrollView];
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>RTRotateDelegate<<<<<<<<<<<<<<<<<<<<
- (void)viewOriginChangedToRect:(CGRect)rect{
    if (((NSInteger)rect.origin.x != (NSInteger)_lastX)&&(!_currentImageViewIsRotating)){
        _xVelocity = rect.origin.x - _lastX;
        _dY = rect.origin.y - _lastY;
        if ((_dY > -10)&&(_dY < 10)) {
            _dY = 0.0;
        }
        _lastX = rect.origin.x;
        _lastY = rect.origin.y;
    }
    if ((_currentImageView.frame.size.width >= self.frame.size.width-1)&&(!_currentImageViewIsRotating)) {
        if ((_currentImageView.frame.size.height <= self.frame.size.height+1)&&(_currentImageView.frame.size.height >= self.frame.size.height-1)) {
            _currentImageView.frame = CGRectMake(_currentImageView.frame.origin.x, 0, _currentImageView.frame.size.width, _currentImageView.frame.size.height);
        }
        if(((rect.size.width + rect.origin.x) > 0)&&((rect.size.width + rect.origin.x) < self.frame.size.width)){
            [UIView animateWithDuration:0.05 animations:^{
                            _ScrollView.contentOffset = CGPointMake((self.frame.size.width - (rect.size.width + rect.origin.x)) + _currentImageNumber*_ScrollView.frame.size.width, _ScrollView.contentOffset.y);
            }];
        }
        else if ((rect.origin.x > 0)&&(rect.origin.x < self.frame.size.width)){
            [UIView animateWithDuration:0.05 animations:^{
                            _ScrollView.contentOffset = CGPointMake(-rect.origin.x + _currentImageNumber*_ScrollView.frame.size.width, _ScrollView.contentOffset.y);
            }];
        }
    }

}
- (void)endPanWithFrame:(CGRect)rect{
    [self enlargementRecovery];
    [self panResultHandleWithRect:rect];
}
- (void)tapedViewWithGesture:(UITapGestureRecognizer *)recognizer{
    [self dismiss];
}
- (void)rotatingWithAngle:(CGFloat)anfle{
    _currentImageViewIsRotating = YES;
    if (_ScrollView.contentOffset.x != _ScrollView.frame.size.width*_currentImageNumber) {
        [UIView animateWithDuration:_animateWithDuration animations:^{
            _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*_currentImageNumber, _ScrollView.contentOffset.y);
        }];
    }
}
- (void)endRotateWithAngle:(CGFloat)anfle{
    _currentImageViewIsRotating = NO;
}
- (void)rotateToOrientation:(RTRotateOrientation)rotateOrientation{
    if ((rotateOrientation == RTRotateOrientationLeft) || (rotateOrientation == RTRotateOrientationRight))
        _allowRecover = NO;
    else
        _allowRecover = YES;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>configView<<<<<<<<<<<<<<<<<<<<
- (void)configView{
    /**
     *  配置手势
     */
    [_currentImageView setRotateEnabled:YES];
    [_currentImageView setRotateMode:RTRotateModeGear];
    [_currentImageView setRotateDelegate:self];
    [_currentImageView setDoubleClickEnlargementEnabled:YES];
    [_currentImageView setMagnifierEnabled:YES];
    [_currentImageView setPanGestureEnabled:YES];
    [_currentImageView setDragEnabled:YES];
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>getImageUrlWithString<<<<<<<<<<<<<<<<<<<<
-(NSURL *)getImageUrlWithString:(NSString *)str{
    NSString *urlStr=str ;
    urlStr=[urlStr  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>isTouchInImageOrNo<<<<<<<<<<<<<<<<<<<<
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _defaultY = _currentImageView.frame.origin.y;
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:_currentImageView];
    BOOL bo = [self isTouchInImageOrNoWithTouchPoint:location];
    if (!bo)
        [_currentImageView setDoubleClickEnlargementEnabled:NO];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_currentImageView setDoubleClickEnlargementEnabled:YES];
}
- (BOOL)isTouchInImageOrNoWithTouchPoint:(CGPoint)point{
    CGRect imageFrame = [self getFrameSizeForImage:_currentImageView.image inImageView:_currentImageView];
    if ((point.x < imageFrame.origin.x) || (point.x > (imageFrame.origin.x + imageFrame.size.width)) || (point.y < imageFrame.origin.y) || (point.y > (imageFrame.origin.y + imageFrame.size.height)))
        return  NO;
    else
        return YES;
}
- (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    float hfactor = image.size.width / imageView.bounds.size.width;
    float vfactor = image.size.height / imageView.bounds.size.height;
    float factor = fmax(hfactor, vfactor);
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    float leftOffset = (imageView.bounds.size.width - newWidth) / 2;
    float topOffset = (imageView.bounds.size.height - newHeight) / 2;
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>myFun<<<<<<<<<<<<<<<<<<<<
- (void)dismiss {
    [_ScrollView removeFromSuperview];
    _currentImageView.backgroundColor = [UIColor clearColor];
    NSValue *rectValue = [_beginRectsData objectAtIndex:_currentImageNumber];
    CGRect rect = rectValue.CGRectValue;
    [UIView animateWithDuration:0.3 animations:^{
        _currentImageView.alpha = 0;
        _currentImageView.frame = rect;
    } completion:^(BOOL finished) {
        if (finished) {
            [self resignKeyWindow];
            self.hidden = YES;
        }
    }];
}
- (void)show {
    [self makeKeyAndVisible];
}
- (void)updataCurrentImageNumber{
    uint32_t i = _ScrollView.contentOffset.x/_ScrollView.frame.size.width;
    _currentImageNumber = i;
}
- (void)enlargementRecovery{
    if (_allowRecover) {
        if (_currentImageView.frame.size.width > self.frame.size.width) {
            CGRect currentImageViewFrame = [self getFrameSizeForImage:_currentImageView.image inImageView:_currentImageView];
            CGFloat yUp = currentImageViewFrame.origin.y + _currentImageView.frame.origin.y;
            CGFloat yDown = yUp + currentImageViewFrame.size.height;
            if (currentImageViewFrame.size.height > self.frame.size.height) {
                if (yUp > 0) {
                    [UIView animateWithDuration:_animateWithDuration animations:^{
                        _currentImageView.frame = CGRectMake( _currentImageView.frame.origin.x,  _currentImageView.frame.origin.y - yUp,  _currentImageView.frame.size.width,  _currentImageView.frame.size.height);
                    }];
                }
                else if (yDown < self.frame.size.height){
                    [UIView animateWithDuration:_animateWithDuration animations:^{
                        _currentImageView.frame = CGRectMake( _currentImageView.frame.origin.x,  _currentImageView.frame.origin.y + (self.frame.size.height - yDown),  _currentImageView.frame.size.width,  _currentImageView.frame.size.height);
                    }];
                }
            }
            else if (currentImageViewFrame.size.height < self.frame.size.height){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    _currentImageView.frame = CGRectMake( _currentImageView.frame.origin.x, - _currentImageView.frame.size.height/2 + self.frame.size.height/2,  _currentImageView.frame.size.width,  _currentImageView.frame.size.height);
                }];
            }
        }
    }
}
- (void)panResultHandleWithRect:(CGRect)rect{
    CGFloat scaleA = 1.0/5.0;
    CGFloat scaleB = 4.0/5.0;
    NSInteger passValue = 10;
    if ((_currentImageView.frame.size.width >= self.frame.size.width-1)&&(!_currentImageViewIsRotating)) {
        if ((((rect.size.width + rect.origin.x) < scaleA*self.frame.size.width)&&((rect.size.width + rect.origin.x) > 0)) || ((_xVelocity < -passValue) && (_dY == 0))) {
            if (_currentImageNumber < _imagesURL.count-1) {
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    _currentImageView.frame = CGRectMake(-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
                    _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*(_currentImageNumber+1), _ScrollView.contentOffset.y);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self updataCurrentImageNumber];
                        [_ScrollView setBlackMaskToImageNumber:_currentImageNumber];
                        [_currentImageView removeFromSuperview];
                        _currentImageView = [[UIImageView alloc]initWithFrame:screenSize];
                        [_currentImageView sd_setImageWithURL:[self getImageUrlWithString:[_imagesURL objectAtIndex:_currentImageNumber]] placeholderImage:[UIImage imageNamed:_holderImage]];
                        _currentImageView.contentMode = UIViewContentModeScaleAspectFit;
                        _currentImageView.backgroundColor = [UIColor blackColor];
                        [_rootVc.view addSubview:_currentImageView];
                        [self configView];
                        NSString *labelText = [NSString stringWithFormat:@"%d/%d",_currentImageNumber+1,(uint32_t)_imagesURL.count];
                        pageLabel.text = labelText;
                        [_rootVc.view bringSubviewToFront:pageLabel];
                    }
                }];
            }
            else if(_currentImageNumber >= _imagesURL.count-1){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    _currentImageView.frame = CGRectMake((self.frame.size.width - rect.size.width),_defaultY, rect.size.width, rect.size.height);
                    _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*_currentImageNumber, _ScrollView.contentOffset.y);
                }];
            }
        }
        else if(((rect.size.width + rect.origin.x) > scaleA*self.frame.size.width)&&((rect.size.width + rect.origin.x) < self.frame.size.width)){
            [UIView animateWithDuration:_animateWithDuration animations:^{
                _currentImageView.frame = CGRectMake((self.frame.size.width - rect.size.width),_defaultY, rect.size.width, rect.size.height);
                _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*_currentImageNumber, _ScrollView.contentOffset.y);
            }];
        }
        else if (((rect.origin.x > scaleB*self.frame.size.width)&&(rect.origin.x < self.frame.size.width)) || ((_xVelocity > passValue) && (_dY == 0))){
            if (_currentImageNumber > 0) {
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    _currentImageView.frame = CGRectMake(self.frame.size.width, rect.origin.y, rect.size.width, rect.size.height);
                    _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*(_currentImageNumber-1), _ScrollView.contentOffset.y);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self updataCurrentImageNumber];
                        [_ScrollView setBlackMaskToImageNumber:_currentImageNumber];
                        [_currentImageView removeFromSuperview];
                        _currentImageView = [[UIImageView alloc]initWithFrame:screenSize];
                        [_currentImageView sd_setImageWithURL:[self getImageUrlWithString:[_imagesURL objectAtIndex:_currentImageNumber]] placeholderImage:[UIImage imageNamed:_holderImage]];
                        _currentImageView.contentMode = UIViewContentModeScaleAspectFit;
                        _currentImageView.backgroundColor = [UIColor blackColor];
                        [_rootVc.view addSubview:_currentImageView];
                        [self configView];
                        NSString *labelText = [NSString stringWithFormat:@"%d/%d",_currentImageNumber+1,(uint32_t)_imagesURL.count];
                        pageLabel.text = labelText;
                        [_rootVc.view bringSubviewToFront:pageLabel];
                    }
                }];
            }
            else if (_currentImageNumber <= 0){
                [UIView animateWithDuration:_animateWithDuration animations:^{
                    _currentImageView.frame = CGRectMake(0, _defaultY, rect.size.width, rect.size.height);
                    _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*_currentImageNumber, _ScrollView.contentOffset.y);
                }];
            }
        }
        else if ((rect.origin.x < scaleB*self.frame.size.width) && (rect.origin.x > 0)){
            [UIView animateWithDuration:_animateWithDuration animations:^{
                _currentImageView.frame = CGRectMake(0, _defaultY, rect.size.width, rect.size.height);
                _ScrollView.contentOffset = CGPointMake(_ScrollView.frame.size.width*_currentImageNumber, _ScrollView.contentOffset.y);
            }];
        }
    }
}
@end
