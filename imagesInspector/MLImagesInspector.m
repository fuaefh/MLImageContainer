//
//  MLImagesInspector.m
//  UICollectionView
//
//  Created by Xiaojie Feng on 16/7/11.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "MLImagesInspector.h"
#import "UIImageView+WebCache.h"


@interface MLImagesInspector ()
{
    NSArray *_imagesURL;
    NSString *_holderImage;
    NSMutableArray *_imageViewArray;
}
@end
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>init<<<<<<<<<<<<<<<<<<<<
@implementation MLImagesInspector
-(id)initWithFrame:(CGRect)frame imagesURL:(NSArray *)urlArray placeHolder:(NSString *)holderImage{
    if (self = [super initWithFrame:frame]) {
        _imagesURL = urlArray;
        _holderImage = holderImage;
        _imageViewArray = [[NSMutableArray alloc]init];
        self.pagingEnabled = YES;
        self.contentSize = CGSizeMake(_imagesURL.count * self.frame.size.width, self.frame.size.height);
        [self setPhotoAlbum];
    }
    return self;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>setPhotoAlbum<<<<<<<<<<<<<<<<<<<<
- (void)setPhotoAlbum{
    for (NSInteger i = 0; i < _imagesURL.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString * url = [_imagesURL objectAtIndex:i];
        [imageView sd_setImageWithURL:[self getImageUrlWithString:url] placeholderImage:[UIImage imageNamed:_holderImage]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        [_imageViewArray addObject:imageView];
        [self addSubview:imageView];
    }
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>getImageUrlWithString<<<<<<<<<<<<<<<<<<<<
-(NSURL *)getImageUrlWithString:(NSString *)str{
    NSString *urlStr=str ;
    urlStr=[urlStr  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
#pragma mark-- >>>>>>>>>>>>>>>>>>>>>setBlackMaskToImageNumber<<<<<<<<<<<<<<<<<<<<
- (void)setBlackMaskToImageNumber:(NSInteger)imageNumber{
    for (NSInteger i = 0; i < _imageViewArray.count; i++) {
        UIImageView *imageView = [_imageViewArray objectAtIndex:i];
        imageView.hidden = NO;
    }
    UIImageView *imageView = [_imageViewArray objectAtIndex:imageNumber];
    imageView.hidden = YES;
}
@end
