//
//  BRSearchView.m
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "BRSearchView.h"
#import "BRSearchViewCell.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ItemBtn : UIButton

@property (nonatomic, strong) id object; //增加一个object属性

@end

@implementation ItemBtn

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHue:237/255.0 saturation:237/255.0 brightness:237/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end


@interface BRSearchView () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UILabel *sectionTitleLabel; //如热门搜索

@property (nonatomic, strong) NSArray *dataArray; //搜索得到的结果
@property (nonatomic, strong) NSMutableArray *recentlySearchArray; //最近搜过(最后都赋值给dataArray,里面存储的是BRSearchModel类型)
@property (nonatomic, strong) NSMutableArray *hotSearchButtons; //热门搜索button

@property (nonatomic, assign) NSInteger colCount; //总共有几列
@property (nonatomic, assign) NSInteger status; // 0:未进行搜索(显示热门搜索、最近搜过) 1:显示搜索结果页面 2:显示搜索结果页面但无数据 默认值是0

@end

@implementation BRSearchView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.frame = [UIScreen mainScreen].bounds;
        
        [self initAttributes];
        [self initTapClick];
        [self initSearchBar];
        [self initTable];
        [self initTableFooterView];
    }
    return self;
}

#pragma mark - init 
- (void)initAttributes {
    _colCount = 3;
    _recentlySearchArray = [NSMutableArray array];
    _hotSearchButtons = [NSMutableArray array];
    
    _status = 0;
    
    // 取出历史数据
    [self.recentlySearchArray addObjectsFromArray:[self getSearchResult]];
    self.dataArray = self.recentlySearchArray;
}

- (void)initTapClick {
    UIControl *closeControl = [[UIControl alloc] initWithFrame:self.bounds];
    [closeControl addTarget:self action:@selector(closebgClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeControl];
}

- (void)initSearchBar {
    UIImageView *searchBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    searchBG.image = [UIImage imageNamed:@"nav.png"];
    [self addSubview:searchBG];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth-55, 44)];
    _searchBar.placeholder = @"搜索商家或地点";
    _searchBar.delegate = self;
    
    _searchBar.backgroundImage = [UIImage imageNamed:@"nav.png"];
    if (!([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)) {
        //修改搜索框背景
        _searchBar.backgroundColor = [UIColor clearColor];
        //去掉搜索框背景
        //1.
        [[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
        //2.
        for (UIView *subview in _searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        _searchBar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"nav.png"]];
        //3自定义背景
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav.png"]];
        imageView.frame=_searchBar.bounds;
        [_searchBar insertSubview:imageView atIndex:0];
        
    }
    [self addSubview:_searchBar];
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-49, 20, 44, 44)];
    [cancleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancleBtn];
}

- (void)initTable {
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStyleGrouped];
    self.table.dataSource = self;
    self.table.delegate = self;
    [self addSubview:self.table];
    
    [self.table registerNib:[UINib nibWithNibName:@"BRSearchViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"BRSearchViewCell"];
}

- (void)initTableFooterView {
    if (self.recentlySearchArray.count > 0) {
        // 有历史数据，显示清除搜索记录
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        self.tableFooterView.backgroundColor = [UIColor whiteColor];
        
        UIButton *clearBtn = [[UIButton alloc] initWithFrame:self.tableFooterView.bounds];
        [clearBtn setTitle:@"清除搜索记录" forState:UIControlStateNormal];
        [clearBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableFooterView addSubview:clearBtn];
        
        self.table.tableFooterView = self.tableFooterView;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""] || [searchText isEqualToString:@" "] || searchText == nil) {
        _status = 0;
        self.table.tableHeaderView = self.tableHeaderView;
        self.table.tableFooterView = self.tableFooterView;
        self.dataArray = self.recentlySearchArray;
        [self.table reloadData];
        return;
    }
    
    // 只要不为空就出现数据(可以根据需要替换成网络数据)
    self.dataArray = [self dataPrepareWithString:searchText];
    if (self.dataArray.count == 0) {
        _status = 2;
    }else {
        _status = 1;
    }
    self.table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    [self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 暂时不做处理
}

#pragma mark - UITableViewDataSourceDelegate and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_status == 2) {
        return 1;
    }
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_status == 0) {
        if (self.dataArray.count > 0) {
            return 30; //未搜索有头部
        }
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_status == 0) {
        if (self.dataArray.count > 0) {
            UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
            UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth, 30)];
            sectionHeaderLabel.textColor = [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1.0];
            sectionHeaderLabel.text = @"最近搜过";
            sectionHeaderLabel.font = [UIFont systemFontOfSize:16];
            
            [sectionHeaderView addSubview:sectionHeaderLabel];
            return sectionHeaderView;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BRSearchViewCell" forIndexPath:indexPath];
    [cell configCellWithModel:self.dataArray[indexPath.row] status:_status];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BRSearchModel *searchModel = self.dataArray[indexPath.row];
    
    [self storeSearchResult:searchModel];
    if ([self.delegate respondsToSelector:@selector(brSearchView:selectedSearchModel:)]) {
        [self.delegate brSearchView:self selectedSearchModel:searchModel];
    }
    [self hidden];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

#pragma mark - getters and setters
- (void)setHotSearchArray:(NSArray *)hotSearchArray {
    _hotSearchArray = hotSearchArray;
    
    /** 配置表的头部视图 */
    CGFloat padding = 10;
    CGFloat btnWidth = (ScreenWidth-(_colCount+1)*padding)/_colCount;
    CGFloat btnHeight = 44;
    
    CGFloat tableHaderViewH = 0;
    NSInteger rowCount = 0;
    if (hotSearchArray.count % _colCount !=0 ) {
        rowCount = hotSearchArray.count / _colCount + 1;
    }else {
        rowCount = hotSearchArray.count / _colCount;
    }
    
    CGFloat sectionTitleLabelH = 44;
    if (hotSearchArray.count == 0) {
        tableHaderViewH = sectionTitleLabelH+20;
    }else {
        tableHaderViewH = sectionTitleLabelH + (rowCount+1)*padding + rowCount*btnHeight;
    }
    
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, tableHaderViewH)];
    
    _sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 120, 20)];
    _sectionTitleLabel.textColor = [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1.0];
    _sectionTitleLabel.font = [UIFont systemFontOfSize:16];
    _sectionTitleLabel.text = @"热门搜索";
    [self.tableHeaderView addSubview:_sectionTitleLabel];
    
    if (hotSearchArray.count == 0) {
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, CGRectGetMaxY(_sectionTitleLabel.frame)+5, 120, 20)];
        msgLabel.textColor = [UIColor lightGrayColor];
        msgLabel.font = [UIFont systemFontOfSize:14];
        msgLabel.text = @"暂无数据";
        [self.tableHeaderView addSubview:msgLabel];
        self.table.tableHeaderView = self.tableHeaderView;
        return;
    }
    
    for (int i = 0; i<hotSearchArray.count; i++) {
        NSInteger row = i / _colCount;
        NSInteger col = i % _colCount;
        
        CGFloat x = padding*(col+1) + btnWidth*col;
        CGFloat y = padding*(row+1) + btnHeight*row+CGRectGetMaxY(_sectionTitleLabel.frame);
        
        ItemBtn *btn = [[ItemBtn alloc] initWithFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        
        BRSearchModel *searchModel = hotSearchArray[i];
        btn.object = searchModel;
        [btn setTitle:searchModel.name forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableHeaderView addSubview:btn];
        
        [self.hotSearchButtons addObject:btn];
    }
    
    self.table.tableHeaderView = self.tableHeaderView;
}

#pragma mark - event response
- (void)cancleClick:(UIButton *)sender {
    [self hidden];
}

/** 热门搜索点击 */
- (void)btnClick:(ItemBtn *)btn {
    BRSearchModel *searchModel = btn.object;

    [self storeSearchResult:searchModel];
    if ([self.delegate respondsToSelector:@selector(brSearchView:selectedSearchModel:)]) {
        [self.delegate brSearchView:self selectedSearchModel:searchModel];
    }
    [self hidden];
}

/** 清除搜索历史记录 */
- (void)clearClick:(UIButton *)btn {
    [self clearSearchResult];
    [self.recentlySearchArray removeAllObjects];
    
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    [self.table reloadData];
}

- (void)closebgClick {
    [self hidden];
}

- (void)show {
    [_searchBar becomeFirstResponder];
    _searchBar.text = @"";
    _searchBar.returnKeyType = UIReturnKeySearch;
    self.hidden = NO;
    [self.table reloadData];
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hidden {
    [_searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark 存储、取出、清除历史搜索记录
- (void)storeSearchResult:(BRSearchModel *)searchModel {
    if (self.recentlySearchArray.count > 0) {
        [self.recentlySearchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BRSearchModel *tempModel = obj;
            if ([searchModel.uid integerValue] == [tempModel.uid integerValue]) {
                [self.recentlySearchArray removeObjectAtIndex:idx];
            }
        }];
    }
    
    if (self.recentlySearchArray.count >= 10) {
        [self.recentlySearchArray removeLastObject];
    }
    
    [self.recentlySearchArray insertObject:searchModel atIndex:0];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int i = 0; i<self.recentlySearchArray.count; i++) {
        BRSearchModel *model = self.recentlySearchArray[i];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        [mutableArray addObject:data];
    }
    
    NSArray *searchArray = [NSArray arrayWithArray:mutableArray];
    [[NSUserDefaults standardUserDefaults] setObject:searchArray forKey:@"RecentlySearchResultKey"];
}

- (NSMutableArray *)getSearchResult {
    NSArray *searchArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlySearchResultKey"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int i = 0; i<searchArray.count; i++) {
        NSData *data = searchArray[i];
        BRSearchModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [mutableArray addObject:model];
    }
    
    return mutableArray;
}

- (void)clearSearchResult {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RecentlySearchResultKey"];
}

#pragma mark - private methods
/** 模拟搜索结果(实际项目中走的是网络) */
- (NSMutableArray *)dataPrepareWithString:(NSString *)string {
    if ([string isEqualToString:@"A"] || [string isEqualToString:@"a"]) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (int i = 0; i<10; i++) {
            BRSearchModel *searchModel = [[BRSearchModel alloc] init];
            searchModel.uid = [NSString stringWithFormat:@"200%d", i];
            searchModel.name = [NSString stringWithFormat:@"嘟嘟牛网咖%d", i];
            [mutableArray addObject:searchModel];
        }
        
        return mutableArray;
    }
    return nil;
}

@end
