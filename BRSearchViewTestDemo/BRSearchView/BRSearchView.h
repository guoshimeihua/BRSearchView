//
//  BRSearchView.h
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSearchModel.h"
@class BRSearchView;
@protocol BRSearchViewDelegate <NSObject>

@required
- (void)brSearchView:(BRSearchView *)brSearchView selectedSearchModel:(BRSearchModel *)selectedSearchModel;

@end

@interface BRSearchView : UIView

@property (nonatomic, weak) id<BRSearchViewDelegate> delegate;
@property (nonatomic, strong) NSArray *hotSearchArray; //热门搜索

- (void)show;
- (void)hidden;

@end
