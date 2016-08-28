//
//  WPhotoBrowser.m
//  WaterfallFlow
//
//  Created by winter on 16/8/28.
//  Copyright © 2016年 d. All rights reserved.
//

#import "WPhotoBrowser.h"
#import "UIImageView+WebCache.h"

#define W_ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define W_ScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface WPhotoBrowserCellModel : NSObject
/** 是否下载过 */
@property (nonatomic, assign) BOOL hasDownloaded;
/** 下载成功 */
@property (nonatomic, assign) BOOL downloadSuccess;
@property (nonatomic, assign) CGFloat downloadProgress;

@property (nonatomic, strong) UIImage *placeholderImage;
/** 要显示的图片地址 */
@property (nonatomic, strong) NSURL *imageURL;
@end
@interface WPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, copy) void (^dissmissBlock)();
@property (nonatomic, strong) WPhotoBrowserCellModel *cellModel;
@end

@interface WPhotoBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray<WPhotoBrowserCellModel*> *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation WPhotoBrowser

- (instancetype)initWithCurrentImageIndex:(NSInteger)currentIndex imageTotalCount:(NSInteger)imageTotalCount
{
    WPhotoBrowser *photoBrowser = [WPhotoBrowser new];
    photoBrowser.currentImageIndex = currentIndex;
    photoBrowser.imageTotalCount = imageTotalCount;
    return photoBrowser;
}

- (instancetype)initWithDelegate:(id<WPhotoBrowserDelegate>)delegate
{
    WPhotoBrowser *photoBrowser = [WPhotoBrowser new];
    photoBrowser.delegate = delegate;
    return photoBrowser;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, W_ScreenWidth, W_ScreenHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setDelegate:(id<WPhotoBrowserDelegate>)delegate
{
    _delegate = delegate;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.imageTotalCount];
    
    BOOL respondsURL = [delegate respondsToSelector:@selector(photoBrowser:heightQualityImageAtIndex:)];
    
    NSAssert(respondsURL, @"must implementation the method [photoBrowser:heightQualityImageAtIndex:]");
    
    BOOL respondsImage = [delegate respondsToSelector:@selector(photoBrowser:placeholderImageAtIndex:)];
    
    
    for (int i = 0; i < self.imageTotalCount; i++) {
        WPhotoBrowserCellModel *model = [[WPhotoBrowserCellModel alloc] init];
        if (respondsImage) {
            model.placeholderImage = [self.delegate photoBrowser:self placeholderImageAtIndex:i];
        }
        else model.placeholderImage = [UIImage imageNamed:@""];
        model.imageURL = [delegate photoBrowser:self heightQualityImageAtIndex:i];
        [array addObject:model];
    }
    
    self.dataArray = [array copy];
}

- (void)showAtView:(UIView *)view
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    CGPoint startPoint = [view convertPoint:view.center toView:window];
    
    NSLog(@"startPoint = %@",NSStringFromCGPoint(startPoint));
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    
    [window addSubview:self];
    // 显示动画
    
}

- (void)dissmiss
{
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - collectionViewDatasource 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WPhotoBrowserCellModel *model = self.dataArray[indexPath.item];
    cell.cellModel = model;
    
    __weak typeof(self) weakSelf = self;
    cell.dissmissBlock = ^(){
        [weakSelf dissmiss];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentImageIndex = indexPath.item;
}

#pragma mark - setter & getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(W_ScreenWidth, W_ScreenHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 5;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[WPhotoBrowserCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
@end


@implementation WPhotoBrowserCellModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadProgress = 0.0;
    }
    return self;
}

@end

@interface WPhotoBrowserCell ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPinchGestureRecognizer *pin;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGFloat lastScale;
@end

@implementation WPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    [self addSubview:self.imageView];
    
    [self.imageView addGestureRecognizer:self.doubleTap];
    [self.imageView addGestureRecognizer:self.singleTap];
    [self.imageView addGestureRecognizer:self.pin];
    [self.imageView addGestureRecognizer:self.pan];
}

- (void)setCellModel:(WPhotoBrowserCellModel *)cellModel
{
    _cellModel = cellModel;
    self.lastScale = 1.0;
    
    if (cellModel.hasDownloaded) {
        if (cellModel.downloadSuccess) {
            [self.imageView sd_setImageWithURL:cellModel.imageURL];
        }
        else [self downloadImage];
    }
    else {
        [self downloadImage];
    }
}

- (void)downloadImage
{
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:self.cellModel.imageURL
                      placeholderImage:self.cellModel.placeholderImage
                               options:SDWebImageRetryFailed
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  [weakSelf downloadProgress:(CGFloat)receivedSize/expectedSize];
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     
    }];
}

- (void)downloadProgress:(CGFloat)progress
{
    self.cellModel.downloadProgress = progress;
}

- (void)dealloc
{
    // 取消请求
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
}

#pragma mark - action

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 只响应imageView的 tap事件
    return self.imageView;
}

- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"doubleTapAction");
    
    UIView *view = recognizer.view;
    
    CGFloat scale = 0.0;
    if (self.lastScale < 2.0) {
        // 放大
        scale = 2.0;
    }
    else {
        // 缩小
        scale = 1.0;
    }
    self.lastScale = scale;
    
    view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)singleTapAction:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"singleTapAction");
    if (self.dissmissBlock) {
        self.dissmissBlock();
    }
}

// 缩放
- (void)pinAction:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pinAction end scale = %f",self.lastScale);
        [self performSelector:@selector(minScale) withObject:nil afterDelay:.25];
    }
    
    CGFloat scale = 1.0 - (self.lastScale - recognizer.scale);

    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [self.imageView setTransform:newTransform];
    
    self.lastScale = recognizer.scale;
}

- (void)minScale
{
    CGFloat scale = 0.8;
    if (self.lastScale < scale) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue = [NSNumber numberWithDouble:self.lastScale];
        animation.toValue = [NSNumber numberWithDouble:scale];
        animation.duration = 0.25;
//        animation.repeatCount = 1;
        animation.autoreverses = NO;
        animation.removedOnCompletion = YES;
        [self.imageView.layer addAnimation:animation forKey:@"scale"];
//        self.lastScale = scale;
    }
}

// 拖动
- (void)panAction:(UIPanGestureRecognizer *)recognizer
{
    
}

#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{

//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (self.lastScale > 1.0) {
//            return YES;
//        }
//        else return NO;
//    }
//    else return YES;
//}

#pragma mark - setter & getter

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UITapGestureRecognizer *)doubleTap
{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.delaysTouchesBegan=YES;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        _singleTap.delaysTouchesBegan = YES;
        _singleTap.numberOfTapsRequired = 1;
        // 只能识别一种
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}

- (UIPinchGestureRecognizer *)pin
{
    if (!_pin) {
        _pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinAction:)];
    }
    return _pin;
}

- (UIPanGestureRecognizer *)pan
{
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _pan.maximumNumberOfTouches = 1;
        _pan.delegate = self;
    }
    return _pan;
}
@end