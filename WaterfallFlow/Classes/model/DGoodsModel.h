//
//  DGoodsModel.h
//  WaterfallFlow
//
//  Created by wwinter on 16/1/7.
//  Copyright © 2016年 d. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGoodsModel : NSObject

@property (nonatomic, assign) NSInteger h; // 商品图片高
@property (nonatomic, assign) NSInteger w; // 商品图片宽
@property (nonatomic, copy) NSString *img; // 商品图片地址
@property (nonatomic, copy) NSString *price; // 商品价格

+ (instancetype)goodModelWithDict:(NSDictionary *)dict;

// 获取 fake data
+ (NSArray *)loadDataWithDataIndex:(NSInteger)index;
@end
