//
//  RegisterTableViewCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/9.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "RegisterTableViewCell.h"

@implementation RegisterTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.textLabel.highlightedTextColor = RGBColor(0, 194, 155);
    
    // Configure the view for the selected state
}

#pragma mark 设置Cell的边框宽度

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 10;
    frame.size.width -= 2 * 10;
    self.layer.cornerRadius = 10;
    [super setFrame:frame];
}

@end
