//
//  DWaterfallFlowLayout.h
//  WaterfallFlow
//
//  Created by wwinter on 16/1/7.
//  Copyright © 2016年 d. All rights reserved.
//

/**  这种布局 只适应单个section  */

#import <UIKit/UIKit.h>

@protocol DWaterfallFlowLayoutDelegate <NSObject>

@required
- (NSInteger)waterfallFlowColumnCount;
- (CGSize)waterfallFlowItemSizeWithIndexPath:(NSIndexPath *)indexPath;

@end
@interface DWaterfallFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak)  id<DWaterfallFlowLayoutDelegate>flowLayooutDelegate;
@end
