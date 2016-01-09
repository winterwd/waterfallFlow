//
//  ViewController.m
//  WaterfallFlow
//
//  Created by wwinter on 16/1/6.
//  Copyright © 2016年 d. All rights reserved.
//

#import "ViewController.h"
#import "DWaterfallFlowCell.h"
#import "DWaterfallFlowFooterView.h"
#import "DWaterfallFlowLayout.h"

@interface ViewController ()<DWaterfallFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet DWaterfallFlowLayout *waterfallFlowLayout;
@property (nonatomic, strong) DWaterfallFlowFooterView *footerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, getter=isDataLoading) BOOL dataLoading;
@end

@implementation ViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.waterfallFlowLayout.flowLayooutDelegate = self;
    [self loadFakeData];
}

#pragma mark - data

static NSInteger dataIndex = 0;
- (void)loadFakeData
{
    [self.dataArray addObjectsFromArray:[DGoodsModel loadDataWithDataIndex:dataIndex]];
    dataIndex++;

    [self.collectionView reloadData];
}

#pragma mark - flowLayooutDelegate delegate

- (NSInteger)waterfallFlowColumnCount
{
    return 3;
}

- (CGSize)waterfallFlowItemSizeWithIndexPath:(NSIndexPath *)indexPath
{
    DGoodsModel *model = self.dataArray[indexPath.row];
    return CGSizeMake(model.w, model.h);
}

#pragma mark - datasource delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DWaterfallFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.goodModel = self.dataArray[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (UICollectionElementKindSectionFooter == kind) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        return self.footerView;
    }
    return nil;
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.footerView || self.isDataLoading) {
        return;
    }
    if (self.footerView.frame.origin.y < scrollView.contentOffset.y + scrollView.contentSize.height + 50) {
        NSLog(@"开始加载数据");
        self.footerView.hidden = NO;
        self.dataLoading = YES;
        [self.footerView.activityIndicator startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.footerView.activityIndicator stopAnimating];
            self.footerView = nil;
            [self loadFakeData];
            self.dataLoading = NO;
            
        });
    }
}
@end
