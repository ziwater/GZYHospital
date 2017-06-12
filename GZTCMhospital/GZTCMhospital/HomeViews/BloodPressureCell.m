//
//  BloodPressureCell.m
//  
//
//  Created by Chris on 15/10/10.
//
//

#import "BloodPressureCell.h"

@implementation BloodPressureCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 设置Cell的边框宽度

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 10;
    frame.size.width -= 2 * 10;
    [super setFrame:frame];
}

@end
