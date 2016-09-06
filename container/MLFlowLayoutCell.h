//
//  flowLayoutCell
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/6/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLFlowLayoutCell : UICollectionViewCell
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,copy)NSURL *imageUrl;
@end
