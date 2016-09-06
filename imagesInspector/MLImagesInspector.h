//
//  MLImagesInspector.h
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/11.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MLImagesInspector : UIScrollView
/**
 *  背景滚动视图初始化
 *
 *  @param frame       位置大小
 *  @param urlArray    图片资源数组
 *  @param holderImage 占位图
 *
 *  @return 滚动视图实例
 */
- (id)initWithFrame:(CGRect)frame
          imagesURL:(NSArray *)urlArray
        placeHolder:(NSString *)holderImage;
/**
 *  设置当前显示的item不可见
 *
 *  @param imageNumber 当前显示的itemNumber
 */
- (void)setBlackMaskToImageNumber:(NSInteger)imageNumber;
@end
