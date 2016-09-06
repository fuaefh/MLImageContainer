//
//  MLImageContainerView.h
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/6/30.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLImageContainerView : UICollectionView
/**
 *  重新加载CollectionView
 *
 *  @param aArray      图片资源地址数组
 *  @param colum       指定列数
 *  @param placeHolder 占位图
 */
- (void)reloadViewWithImageURLs:(NSArray *)aArray
                          colum:(NSInteger)colum
                    placeHolder:(NSString *)placeHolder;
@end
