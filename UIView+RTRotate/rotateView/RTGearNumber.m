//
//  RTGearNumber.m
//  rotate
//
//  Created by MacBook on 16/6/21.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "RTGearNumber.h"

@interface RTGearNumber (){
     CGFloat _rotateAngle;
}
@end
@implementation RTGearNumber
+ (RTGearNumber *)sharedManager{
    static RTGearNumber *sharedRotateViewInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedRotateViewInstance = [[self alloc] init];
    });
    return sharedRotateViewInstance;
}
- (NSInteger)rightAngleNumber{
    int number = _rotateAngle / 1.571;
    return number;
}
- (CGFloat)remainderAngle{
    CGFloat number = _rotateAngle - 1.571 * [self rightAngleNumber];
    return number;
}
- (NSInteger)gearsNumber{
    NSInteger argument = 1;
    NSInteger rightAngleN = [self rightAngleNumber];
    CGFloat remainderA = [self remainderAngle];
    if (remainderA < 0) {
        rightAngleN = -rightAngleN;
        argument = -1;
        remainderA = -remainderA;
    }
    NSInteger gearsNum;
    if (remainderA <= 0.8) {
        gearsNum = rightAngleN;
    }
    else{
        gearsNum = rightAngleN + 1;
    }
    NSInteger val = gearsNum / 4;
    gearsNum = gearsNum - val*4;
    return gearsNum*argument;
}
- (NSInteger)refreshSelfFrameWithAngle:(CGFloat)rotateAngle
{
    _rotateAngle = rotateAngle;
    NSInteger gearsNum = [self gearsNumber];
    if ((gearsNum == -1) || (gearsNum == 3)) {
        return 3;
    }
    else if ((gearsNum == -2) || (gearsNum == 2)){
        return 2;
    }
    else if ((gearsNum == -3) || (gearsNum == 1)){
        return 1;
    }
    else if (gearsNum == 0){
        return 0;
    }
    return 0;
}
-(CGRect)enlargementWithFrame:(CGRect)rect touchPoint:(CGPoint)point scale:(CGFloat)scale gearNumber:(NSInteger)gearNumber{
    CGRect frame;
    if (gearNumber == 0) {
        CGFloat scaleX = point.x / rect.size.width;
        CGFloat scaleY = point.y / rect.size.height;
        CGFloat dx = rect.size.width * scale * scaleX - point.x;
        CGFloat dy = rect.size.height * scale * scaleY - point.y;
        frame = CGRectMake(rect.origin.x - dx, rect.origin.y - dy, rect.size.width * scale, rect.size.height*scale);
        return  frame;
    }
    else if (gearNumber == 1){
        CGFloat scaleX = point.x / rect.size.height;
        CGFloat scaleY = point.y / rect.size.width;
        CGFloat dx = rect.size.height * scale * scaleX - point.x;
        CGFloat dy = rect.size.width * scale * scaleY - point.y;
        frame = CGRectMake(rect.origin.x - rect.size.width*(scale - 1) + dy, rect.origin.y - dx, rect.size.width * scale, rect.size.height*scale);
        return  frame;
    }
    else if (gearNumber == 2){
        CGFloat scaleX = point.x / rect.size.width;
        CGFloat scaleY = point.y / rect.size.height;
        CGFloat dx = rect.size.width * scale * scaleX - point.x;
        CGFloat dy = rect.size.height * scale * scaleY - point.y;
        frame = CGRectMake(rect.origin.x - (rect.size.width*(scale-1)-dx), rect.origin.y - (rect.size.height*(scale-1)-dy), rect.size.width * scale, rect.size.height*scale);
        return  frame;
    }
    else if (gearNumber ==3){
        CGFloat scaleX = point.x / rect.size.height;
        CGFloat scaleY = point.y / rect.size.width;
        CGFloat dx = rect.size.height * scale * scaleX - point.x;
        CGFloat dy = rect.size.width * scale * scaleY - point.y;
        frame = CGRectMake(rect.origin.x - dy, rect.origin.y - (rect.size.height * (scale - 1) - dx), rect.size.width * scale, rect.size.height*scale);
        return  frame;
    }
    return  frame;
}
-(NSInteger)gearNumberWithLastGearNumber:(NSInteger)lastgear gearSkew:(NSInteger)number{
    if (lastgear == 0) {
        if (number == 0) {
            return 0;
        }
        else if (number == 3){
            return 3;
        }
        else if (number == 2){
            return 2;
        }
        else if (number == 1){
            return 1;
        }
    }
    if (lastgear == 3) {
        if (number == 0) {
            return 3;
        }
        else if (number == 3){
            return 2;
        }
        else if (number == 2){
            return 1;
        }
        else if (number == 1){
            return 0;
        }
    }
    if (lastgear == 2) {
        if (number == 0) {
            return 2;
        }
        else if (number == 3){
            return 1;
        }
        else if (number == 2){
            return 0;
        }
        else if (number == 1){
            return 3;
        }
    }
    if (lastgear == 1) {
        if (number == 0) {
            return 1;
        }
        else if (number == 3){
            return 0;
        }
        else if (number == 2){
            return 3;
        }
        else if (number == 1){
            return 2;
        }
    }
    return 0;
}
@end
