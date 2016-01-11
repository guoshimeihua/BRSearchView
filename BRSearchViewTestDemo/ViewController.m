//
//  ViewController.m
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "ViewController.h"
#import "BRSearchView.h"
#import "BRSearchModel.h"

@interface ViewController () <BRSearchViewDelegate>

@property (nonatomic, strong) BRSearchView *searchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initRightItemButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BRSearchViewDelegate
- (void)brSearchView:(BRSearchView *)brSearchView selectedSearchModel:(BRSearchModel *)selectedSearchModel {
    NSLog(@"统一输出 uid is : %@ name is : %@", selectedSearchModel.uid, selectedSearchModel.name);
}

#pragma mark - event response
- (void)initRightItemButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.bounds = CGRectMake(0, 0, 44, 44);
    
    [btn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [btn setTintColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)searchClick:(id)sender {
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
}

@end
