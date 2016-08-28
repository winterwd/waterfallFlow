//
//  DGoodsModel.m
//  WaterfallFlow
//
//  Created by wwinter on 16/1/7.
//  Copyright © 2016年 d. All rights reserved.
//

#import "DGoodsModel.h"

@implementation DGoodsModel

+ (instancetype)goodModelWithDict:(NSDictionary *)dict
{
    id good = [[self alloc] init];
    [good setValuesForKeysWithDictionary:dict];
    return good;
}

// 获取 fake data
+ (NSArray *)loadDataWithDataIndex:(NSInteger)index
{
    NSString *dataName = [NSString stringWithFormat:@"data_%ld.plist",index % 3 + 1];
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:dataName ofType:nil];
    
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:dataPath];
    
    NSMutableArray *goodsArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    
    [dataArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DGoodsModel *model = [DGoodsModel goodModelWithDict:obj];
        [goodsArray addObject:model];
    }];
    return goodsArray;
}

@end
