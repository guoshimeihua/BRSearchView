#BRSearchView
搜索框
Xcode7.1

# 框架说明
    1.该框架不依赖任何框架，可以直接使用
    2.支持自定义热门搜索
    3.自动记录历史搜索
    4.全部使用代理进行回调
    5.支持7.0及以上，仅支持竖屏
    
    
# 效果预览
![image](https://github.com/guoshimeihua/BRSearchView/blob/master/BRSearchViewTestDemo/BRSearchView/demo22.gif)

# 使用说明
### 1.导入
直接把工程中的BRSearchView文件拖入到工程中即可
        
### 2.设置热门搜索
    _searchView = [[BRSearchView alloc] init];
    _searchView.delegate = self;
    NSMutableArray *hotSearchArray = [NSMutableArray array];
    for (int i = 0; i<8; i++) {
        BRSearchModel *model = [[BRSearchModel alloc] init];
        model.uid = [NSString stringWithFormat:@"100%d", i];
        model.name = [NSString stringWithFormat:@"网鱼网咖%d", i];
        [hotSearchArray addObject:model];
    }
    
    _searchView.hotSearchArray = [NSArray arrayWithArray:hotSearchArray];
    [_searchView show];
  
  
### 3.搜索选中事件回调
    #pragma mark - BRSearchViewDelegate
    - (void)brSearchView:(BRSearchView *)brSearchView selectedSearchModel:(BRSearchModel *)selectedSearchModel {
    NSLog(@"统一输出 uid is : %@ name is : %@", selectedSearchModel.uid, selectedSearchModel.name);
    }
    
    
#结束语
   希望对大家有所帮助



#MIT
此框架基于MTL协议开源
