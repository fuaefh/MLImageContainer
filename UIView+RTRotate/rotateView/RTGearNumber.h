//
//  RTGearNumber.h
//  rotate
//
//  Created by MacBook on 16/6/21.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RTGearNumber : NSObject
/**
 *  初始化并共享实例对象
 *
 *  @return 返回RTGearNumber唯一实例
 */
+ (RTGearNumber *)sharedManager;
/**
 *  根据视图旋转的角度值，判断其是旋转到下一个档位还是回到原位
 *
 *  @param rotateAngle 旋转角度
 *
 *  @return 相对原位置的档位值
 */
- (NSInteger)refreshSelfFrameWithAngle:(CGFloat)rotateAngle;
/**
 *  根据视图上一次旋转后的绝对档位值以及此次旋转的档位偏移值，计算出此时的绝对档位值
 *
 *  @param lastgear 上一次的绝对档位值
 *  @param number   档位偏移
 *
 *  @return 视图旋转后的绝对档位值
 */
- (NSInteger)gearNumberWithLastGearNumber:(NSInteger)lastgear gearSkew:(NSInteger)number;
/**
 *  双击放大之后的视图frame，保证双击的点在放大的过程中不产生位移
 *
 *  @param rect       视图frame
 *  @param point      双击想对视图坐标位置
 *  @param scale      放大比例
 *  @param gearNumber 此时的绝对档位值
 *
 *  @return 视图放大后的frame
 */
- (CGRect)enlargementWithFrame:(CGRect)rect touchPoint:(CGPoint)point scale:(CGFloat)scale gearNumber:(NSInteger)gearNumber;


@end
