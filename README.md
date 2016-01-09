# waterfallFlow
waterfallFlow layout

参照源码    https://github.com/lengmolehongyan/WaterfallFlowDemo.git

以及blog   http://www.cnblogs.com/purple-sweet-pottoes/p/4833558.html

进行略微的修正 对源码进行了 数据解耦

继承自 UICollectionViewFlowLayout 进行布局计算

必须实现 这两个方法

- (NSInteger)waterfallFlowColumnCount;
- (CGSize)waterfallFlowItemSizeWithIndexPath:(NSIndexPath *)indexPath;

