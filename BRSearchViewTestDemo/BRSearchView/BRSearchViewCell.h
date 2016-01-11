//
//  BRSearchViewCell.h
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSearchModel.h"

@interface BRSearchViewCell : UITableViewCell

/** status三种状态 0:未搜索页面 1:搜索页面 2:搜索无结果页面 */
- (void)configCellWithModel:(BRSearchModel *)model status:(NSInteger)status;

@end
