//
//  LGCycleCollectionView.m
//  UICollectionView无限轮播
//
//  Created by admin on 16/8/26.
//  Copyright © 2016年 LaiCunBa. All rights reserved.
//

#import "LGCycleCollectionView.h"
#import "LGCycleCell.h"

static NSString *cellIdentifier = @"cell";

@interface LGCycleCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger _currentItem;
}

@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) NSMutableArray *imagesArray;
@property (nonatomic , strong) NSMutableArray *titlesArray;
@property (nonatomic , assign) NSInteger imagesCount;
@property (nonatomic , strong) NSTimer *timer;


@end

@implementation LGCycleCollectionView


- (instancetype)initWithFrame:(CGRect)frame ImagesArray:(NSArray *)images TitleArray:(NSArray *)titles
{
    self = [super init];
    if (self) {
        
        self.frame = frame;
        
        if (images.count != 0) {
            [self setupWithImages:images];
        }
        
        
    }
    return self;
}

- (void)setupWithImages:(NSArray *)images
{
    self.imagesArray = [self setImagesArrayWithImages:images];
    //            self.titlesArray = [self setImagesArrayWithImages:titles];
    self.imagesCount = self.imagesArray.count;
    [self collectionView];
    [self addTiemr];
}


- (NSMutableArray *)setImagesArrayWithImages:(NSArray *)images
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:images];
    [array insertObject:images[0] atIndex:images.count];
    [array insertObject:images[images.count - 1] atIndex:0];
    
    return array;
}

- (void)setImageNameArray:(NSArray *)imageNameArray
{
    _imageNameArray = imageNameArray;
    
    [self setupWithImages:imageNameArray];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imagesCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.pictureView.image = [UIImage imageNamed:self.imagesArray[indexPath.row]];
    cell.label.text = self.titlesArray[indexPath.row];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat contentOffsetLast = self.collectionView.frame.size.height * (_imagesCount - 1);
    if (scrollView.contentOffset.y == contentOffsetLast) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    } else if (scrollView.contentOffset.y == 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:(_imagesCount - 2) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    
}

- (void)addTiemr
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerWork) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTiemr
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerWork
{
    _currentItem = self.collectionView.contentOffset.y / self.collectionView.frame.size.height;
    NSLog(@"--------%f", self.collectionView.contentOffset.y);
    if (_currentItem == self.imagesArray.count - 2) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        _currentItem = 0;
    }
    
    _currentItem++;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentItem inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTiemr];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTiemr];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = self.frame.size;
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor grayColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[LGCycleCell class] forCellWithReuseIdentifier:cellIdentifier];
        //设置偏移量
        _collectionView.contentOffset = CGPointMake(0, self.frame.size.height);
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)dealloc
{
    NSLog(@">>>>>> dealloc");
}

@end
