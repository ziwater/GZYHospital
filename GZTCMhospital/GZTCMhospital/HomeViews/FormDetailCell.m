//
//  FormDetailCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/14.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "FormDetailCell.h"

@implementation FormDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 设置Cell的边框宽度

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 8;
    frame.size.width -= 2 * 8;
    [super setFrame:frame];
}

@end
