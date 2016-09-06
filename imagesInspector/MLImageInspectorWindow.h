//
//  MLImageInspectorWindow.h
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLImageInspectorWindow : UIWindow

/**
 * 初始化图片查看器
 *
 *  @param frame       查看器大小
 *  @param urlArray    图片资源数组
 *  @param rectArray   图片相对屏幕的起始frame数组
 *  @param holderImage 占位图
 *  @param itemNumber  点击的图片号码
 *
 *  @return 查看器实例
 */
- (id)initWithFrame:(CGRect)frame
          imagesURL:(NSArray *)urlArray
     baginRectsData:(NSArray *)rectArray
        placeHolder:(NSString *)holderImage
    touchItemNumber:(uint32_t)itemNumber;

/**
 *  显示window
 */
- (void)show;

@end
