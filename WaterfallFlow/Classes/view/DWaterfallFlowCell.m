//
//  DWaterfallFlowCell.m
//  WaterfallFlow
//
//  Created by wwinter on 16/1/7.
//  Copyright © 2016年 d. All rights reserved.
//

#import "DWaterfallFlowCell.h"
#import "UIImageView+WebCache.h"

@interface DWaterfallFlowCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
@implementation DWaterfallFlowCell

- (void)setGoodModel:(DGoodsModel *)goodModel
{
    _goodModel = goodModel;
    NSURL *url = [NSURL URLWithString:goodModel.img];
    [self.imageView sd_setImageWithURL:url];
    self.titleLabel.text = goodModel.price;
}
@end
