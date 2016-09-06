# MLImageContainer


#import "MLImageContainerView.h"

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    MLImageContainerView *collectionView = [[MLImageContainerView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    [collectionView reloadViewWithImageURLs:[self getIamgeArray] colum:6 placeHolder:nil];
