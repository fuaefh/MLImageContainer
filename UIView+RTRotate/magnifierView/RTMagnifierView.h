//
//  RTMagnifierView.h
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMagnifierView : UIView
/**
 *  用于放大的view
 */
@property (nonatomic, retain) UIView *viewToMagnify;
/**
 *  放大视图的位置
 */
@property (nonatomic,assign) CGPoint touchPoint;

@end
