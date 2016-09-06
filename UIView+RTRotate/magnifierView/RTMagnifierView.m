//
//  RTMagnifierView.m
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "RTMagnifierView.h"
@interface RTMagnifierView (){
}
@end
@implementation RTMagnifierView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 120, 120)]) {
        self.layer.cornerRadius = 60;
        self.layer.masksToBounds = YES;
        self.layer.backgroundColor = [UIColor greenColor].CGColor;
         self.viewToMagnify = [[UIView alloc]initWithFrame:frame];
    }
    return self;
}
- (void)setTouchPoint:(CGPoint)pt {
    _touchPoint = pt;
    self.center = CGPointMake(pt.x, pt.y-60);
    [self.layer setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 3, 3);
    CGContextTranslateCTM(context,-1*(_touchPoint.x),-1*(_touchPoint.y));
    [self.viewToMagnify.layer renderInContext:context];
}
+ (Class)layerClass{
    return [CAShapeLayer class];
}
@end
