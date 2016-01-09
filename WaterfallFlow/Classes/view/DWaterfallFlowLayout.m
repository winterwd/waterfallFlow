//
//  DWaterfallFlowLayout.m
//  WaterfallFlow
//
//  Created by wwinter on 16/1/7.
//  Copyright © 2016年 d. All rights reserved.
//

#import "DWaterfallFlowLayout.h"
//#import "DGoodsModel.h"

@interface DWaterfallFlowLayout ()

/** 所有item layout 属性数组 */
@property (nonatomic, strong) NSArray *itemLayoutAttributesArray;
/** 显示列数 */
@property (nonatomic, assign) NSInteger columnCount;

/** collectionView contentSize 的最长*/
@property (nonatomic, assign) CGFloat longestColumnHeight;
@end

@implementation DWaterfallFlowLayout

/**
 *  布局前的准备方法，当collectionView布局发生改变时会调用该方法
 *  在这里一般 计算itemSize
 *  collectionView 的contentSize 是根据itemSize 动态计算出来的
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    
    if (![self.flowLayooutDelegate respondsToSelector:@selector(waterfallFlowColumnCount)] || ![self.flowLayooutDelegate respondsToSelector:@selector(waterfallFlowItemSizeWithIndexPath:)]) {
        NSAssert(0, @"waterfallFlowColumnCount & waterfallFlowItemSizeWithIndexPath: 这两个代理方法必须实现");
    }
    // 获得列数
    self.columnCount = [self.flowLayooutDelegate waterfallFlowColumnCount];
    
    // 根据列数 计算出 itemWidth

    // 先计算collectionView 的contentWidth
    CGFloat contentWidth = self.collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right;
    // item之间的space
    CGFloat itemSpace = self.minimumInteritemSpacing;
    CGFloat itemWidth = (contentWidth - (self.columnCount - 1) * itemSpace) / self.columnCount;
    
    // 计算布局
    [self computeItemLayoutAttributesWithItemWidt:itemWidth];
}

/**
 *  根据itemWidth 计算布局属性
 */
- (void)computeItemLayoutAttributesWithItemWidt:(CGFloat)itemWidth
{
    // 定义一个记录每列item的height的数组
    CGFloat columnItemHeight[self.columnCount];
    // 定义一个记录每列item的个数的数组
    NSInteger columnItemCount[self.columnCount];
    
    // 初始化
    for (int i = 0; i < self.columnCount; i++) {
        columnItemHeight[i] = self.sectionInset.top;
        columnItemCount[i] = 0;
    }
    
    // 计算数据源相关属性
    NSInteger dataCount = [self.collectionView numberOfItemsInSection:0]; // 仅适用 单个section
    NSMutableArray *attributesArray = [NSMutableArray arrayWithCapacity:dataCount];
    
    for (int index = 0; index < dataCount; index++) {
        
        // 建立布局属性
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        // 找出最短的列号 (继续添加数据，是跟在最短列号的后面)
        NSInteger shortestColumnIndex = [self shortestColumnIndex:columnItemHeight];
        // 数据追加在最短列，最短列的item数目+1
        columnItemCount[shortestColumnIndex]++;
        
        // 下一个 item的origin itemOriginX itemOriginY 值
        CGFloat itemOriginX = self.sectionInset.left + (itemWidth + self.minimumInteritemSpacing) * shortestColumnIndex;
        CGFloat itemOriginY = columnItemHeight[shortestColumnIndex];
        
        
        // 等比缩放 计算itemHeight
        CGSize itemSize = [self.flowLayooutDelegate waterfallFlowItemSizeWithIndexPath:indexPath];
        CGFloat itemHeight = itemSize.height * itemWidth / itemSize.width;
        
        // 设置frame属性
        attributes.frame = CGRectMake(itemOriginX, itemOriginY, itemWidth, itemHeight);
        [attributesArray addObject:attributes]; // 存储itemFrame属性
        
        // 累加列高
        columnItemHeight[shortestColumnIndex] += itemHeight + self.minimumLineSpacing;
    }
    
    // 找出最高的列号
    NSInteger longestColumnIndex = [self longestColumnIndex:columnItemHeight];
    
    // 获得collectionView contentSize 最高的高度
    self.longestColumnHeight = columnItemHeight[longestColumnIndex];
//     根据最高列设置itemSize 使用总高度的平均值 //设置可滚动显示的区域
//    CGFloat itemH = (columnItemHeight[longestColumnIndex] - self.minimumLineSpacing * columnItemCount[longestColumnIndex]) / columnItemCount[longestColumnIndex];
//    self.itemSize = CGSizeMake(itemWidth, itemH);
    
    // 设置页脚footer属性 footerView
    NSIndexPath *footerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *footerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
    footerAttr.frame = CGRectMake(0, columnItemHeight[longestColumnIndex], self.collectionView.bounds.size.width, 50);
    [attributesArray addObject:footerAttr]; // 存储footerViewFrame属性
    
    // 保存 所有属性
    self.itemLayoutAttributesArray = [attributesArray copy];
}

//
- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, self.longestColumnHeight);
}

/**
 *  跟踪效果：当达到将要显示的区域时，会计算所有显示的item属性
 *          一旦计算完成，所有的属性都会被缓存，不会再次计算
 *  return: 返回布局属性（UICollectionViewLayoutAttributes）数组
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.itemLayoutAttributesArray;
}

/**
 *  计算数组columnItemHeight中最短的列号 数据追加在这个最短的列内
 */
- (NSInteger)shortestColumnIndex:(CGFloat *)columnItemHeight
{
    CGFloat max = MAXFLOAT;
    NSInteger shortestIndex = 0;
    for (int i = 0; i < self.columnCount; i++) {
        if (columnItemHeight[i] < max) {
            // 保持最小的
            max = columnItemHeight[i];
            shortestIndex = i;
        }
    }
    return shortestIndex;
}

/**
 *  计算数组columnItemHeight中最长的列号
 */
- (NSInteger)longestColumnIndex:(CGFloat *)columnItemHeight
{
    CGFloat min = 0;
    NSInteger longestIndex = 0;
    for (int i = 0; i < self.columnCount; i++) {
        if (columnItemHeight[i] > min) {
            // 保持最大的
            min = columnItemHeight[i];
            longestIndex = i;
        }
    }
    return longestIndex;
}
@end
