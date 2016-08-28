//
//  WPhotoBrowser.h
//  WaterfallFlow
//
//  Created by winter on 16/8/28.
//  Copyright © 2016年 d. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WPhotoBrowser;
@protocol WPhotoBrowserDelegate <NSObject>

/** 显示高质量图的URL */
- (NSURL *)photoBrowser:(WPhotoBrowser *)photoBrowser heightQualityImageAtIndex:(NSInteger)index;

@optional
/** 点击首先展示缩略图 */
- (UIImage *)photoBrowser:(WPhotoBrowser *)photoBrowser placeholderImageAtIndex:(NSInteger)index;

@end

@interface WPhotoBrowser : UIView

@property (nonatomic, weak) id<WPhotoBrowserDelegate> delegate;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageTotalCount;

/**
 *  实例化
 *
 *  @param currentIndex    点击当前图片的index
 *  @param imageTotalCount 总共可以显示多少张图片
 *
 *  @return WPhotoBrowser 对象
 */
- (instancetype)initWithCurrentImageIndex:(NSInteger)currentIndex imageTotalCount:(NSInteger)imageTotalCount;

/**
 *  实例化
 *
 *  @param delegate WPhotoBrowserDelegate
 *
 *  @return 遵守协议的 WPhotoBrowser 对象
 */
- (instancetype)initWithDelegate:(id<WPhotoBrowserDelegate>)delegate;

- (void)showAtView:(UIView *)view;
@end