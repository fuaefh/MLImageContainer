//
//  flowLayoutCell
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/6/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "MLFlowLayoutCell.h"

@implementation MLFlowLayoutCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
@end
