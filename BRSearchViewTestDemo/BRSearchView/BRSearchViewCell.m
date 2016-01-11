//
//  BRSearchViewCell.m
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "BRSearchViewCell.h"

@interface BRSearchViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation BRSearchViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithModel:(BRSearchModel *)model status:(NSInteger)status {
    self.nameLabel.textColor = [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1.0];
    if (status == 0) {
        // 未搜索页面
        self.userInteractionEnabled = YES;
        self.iconImgView.hidden = NO;
        self.iconImgView.image = [UIImage imageNamed:@"history"];
        self.nameLabel.text = model.name;
    }else if (status == 1) {
        // 搜索页面
        self.userInteractionEnabled = YES;
        self.iconImgView.hidden = NO;
        self.iconImgView.image = [UIImage imageNamed:@"search"];
        self.nameLabel.text = model.name;
    }else {
        // 搜索无数据页面
        self.userInteractionEnabled = NO;
        self.iconImgView.hidden = YES;
        self.nameLabel.text = @"很抱歉，未找到您想要的数据";
    }
}

@end
