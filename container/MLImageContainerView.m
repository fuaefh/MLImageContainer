//
//  MLImageContainerView.m
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/6/30.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "MLImageContainerView.h"
#import "MLFlowLayoutCell.h"

#import "UIImageView+WebCache.h"
#import "MLImageInspectorWindow.h"

static MLImageInspectorWindow * window;
#define screenSize   [UIScreen mainScreen].bounds

@interface MLImageContainerView() <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *_layoutFlow;
    NSArray *_imageURLs;
    NSMutableArray *_rectDatas;
    NSString *_holderName;
    CGSize _defaultSize;
    NSInteger _colum;
}
@property (nonatomic,retain)UIRefreshControl *refreshControl;
@end

@implementation MLImageContainerView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
            _rectDatas = [[NSMutableArray alloc]init];
            _defaultSize = CGSizeMake(1, 2);
            self.delegate = self;
            self.dataSource = self;
            self.backgroundColor = [UIColor whiteColor];
            [self registerClass:[MLFlowLayoutCell class] forCellWithReuseIdentifier:NSStringFromClass([MLFlowLayoutCell class])];
            _layoutFlow = (UICollectionViewFlowLayout *)layout;
            [self setLayout];
    }
    return self;
}
- (void)setLayout{
    _layoutFlow.itemSize = _defaultSize;
    _layoutFlow.minimumLineSpacing = 0.5;
    _layoutFlow.minimumInteritemSpacing = 0;
    _layoutFlow.sectionInset = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
    _layoutFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
}
#pragma mark-- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        return  _imageURLs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MLFlowLayoutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MLFlowLayoutCell class]) forIndexPath:indexPath];
    cell.imageView.frame = CGRectMake(0, 0, _defaultSize.width, _defaultSize.height);
    if (!_imageURLs) {
        cell.imageView.image = [UIImage imageNamed:_holderName];
    }
    else{
        NSString * url = [_imageURLs objectAtIndex:indexPath.item];
        [cell.imageView sd_setImageWithURL:[self getImageUrlWithString:url] placeholderImage:[UIImage imageNamed:_holderName]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.imageUrl = imageURL;
        }];
    }
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
#pragma mark-- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    uint32_t itemCount = (uint32_t)_imageURLs.count;
    uint32_t currentCellNumber = (uint32_t)indexPath.item + 1;
    NSInteger row = ceilf((CGFloat)((CGFloat)itemCount / (CGFloat)_colum));
    [_rectDatas removeAllObjects];
    CGRect contentViewFrame = [self viewFrameToScreen:self];
    for (NSInteger i = 0; i < row; i++) {
        for (NSInteger j = 0; j < _colum; j++) {
            CGRect rect = CGRectMake(j*self.frame.size.width/_colum + contentViewFrame.origin.x - self.contentOffset.x, _defaultSize.height * i + contentViewFrame.origin.y - self.contentOffset.y, _defaultSize.width, _defaultSize.height);
            NSValue * rectValue = [NSValue valueWithCGRect:rect];
            [_rectDatas addObject:rectValue];
        }
    }
    for (NSInteger i = 0; i < (_rectDatas.count - itemCount); i++) {
        [_rectDatas removeLastObject];
    }
    window = [[MLImageInspectorWindow alloc]initWithFrame:screenSize imagesURL:_imageURLs baginRectsData:_rectDatas placeHolder:_holderName touchItemNumber:currentCellNumber];
    [window show];
}
-(NSURL *)getImageUrlWithString:(NSString *)str{
    NSString *urlStr=str ;
    urlStr=[urlStr  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
-(void)reloadViewWithImageURLs:(NSArray *)aArray colum:(NSInteger)colum placeHolder:(NSString *)placeHolder{
    _imageURLs = aArray;
    _holderName = placeHolder;
    _colum = colum;
    [self layoutIfNeeded];
    if (self.frame.size.height < (self.frame.size.width-(colum+2)/2)/colum)
        _defaultSize = CGSizeMake((self.frame.size.width-(colum+2)/2)/colum, self.frame.size.height-1);
    else
    _defaultSize = CGSizeMake((self.frame.size.width-(colum+2)/2)/colum, (self.frame.size.width-(colum+2)/2)/colum);
    [self setLayout];
    [self reloadData];
}
- (CGRect)viewFrameToScreen:(UIView *)view{
    CGRect viewFrame;
    viewFrame = view.frame;
    if (view.superview) {
        if ([view.superview respondsToSelector:@selector(setContentOffset:)]) {
            UIScrollView * viewSuperview=(UIScrollView *)view.superview;
            viewFrame = CGRectMake(view.superview.frame.origin.x + viewFrame.origin.x - viewSuperview.contentOffset.x, view.superview.frame.origin.y +viewFrame.origin.y - viewSuperview.contentOffset.y, viewFrame.size.width, viewFrame.size.height);
        }
        else
        viewFrame = CGRectMake(view.superview.frame.origin.x + viewFrame.origin.x, view.superview.frame.origin.y +viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    if (view.superview.superview) {
        if ([view.superview.superview respondsToSelector:@selector(setContentOffset:)]) {
            UIScrollView * viewSuperview=(UIScrollView *)view.superview.superview;
            viewFrame = CGRectMake(view.superview.superview.frame.origin.x - viewSuperview.contentOffset.x+ viewFrame.origin.x, view.superview.superview.frame.origin.y +viewFrame.origin.y- viewSuperview.contentOffset.y, viewFrame.size.width, viewFrame.size.height);
        }
        else
        viewFrame = CGRectMake(view.superview.superview.frame.origin.x + viewFrame.origin.x, view.superview.superview.frame.origin.y +viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    if (view.superview.superview.superview) {
        if ([view.superview.superview.superview respondsToSelector:@selector(setContentOffset:)]) {
            UIScrollView * viewSuperview=(UIScrollView *)view.superview.superview.superview;
            viewFrame = CGRectMake(view.superview.superview.superview.frame.origin.x + viewFrame.origin.x- viewSuperview.contentOffset.x, view.superview.superview.superview.frame.origin.y +viewFrame.origin.y- viewSuperview.contentOffset.y, viewFrame.size.width, viewFrame.size.height);
        }
        viewFrame = CGRectMake(view.superview.superview.superview.frame.origin.x + viewFrame.origin.x, view.superview.superview.superview.frame.origin.y +viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    if (view.superview.superview.superview.superview) {
        viewFrame = CGRectMake(view.superview.superview.superview.superview.frame.origin.x + viewFrame.origin.x, view.superview.superview.superview.superview.frame.origin.y +viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    if (view.superview.superview.superview.superview.superview) {
        viewFrame = CGRectMake(view.superview.superview.superview.superview.superview.frame.origin.x + viewFrame.origin.x, view.superview.superview.superview.superview.superview.frame.origin.y +viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    return viewFrame;
}
@end
