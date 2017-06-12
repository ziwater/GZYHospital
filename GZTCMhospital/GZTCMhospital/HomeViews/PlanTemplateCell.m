//
//  PlanTemplateCell.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "PlanTemplateCell.h"

@implementation PlanTemplateCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 设置Cell的边框宽度

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 5;
    frame.size.width -= 2 * 5;
    [super setFrame:frame];
}

@end
