//
//  LoginOrRegisterCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/21.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "LoginOrRegisterCell.h"

@implementation LoginOrRegisterCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    //向通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setEnableRegisterCell:) name:@"setEnableRegisterCell" object:nil];
    
    // Configure the view for the selected state
}

#pragma mark 设置Cell的边框宽度

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 10;
    frame.size.width -= 2 * 10;
    self.layer.cornerRadius = 10;
    self.backgroundColor = RGBColor(207, 207, 207);
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.highlightedTextColor = RGBColor(0, 194, 155);
    [super setFrame:frame];
}

#pragma mark - 通知方法

- (void)setEnableRegisterCell:(NSNotification *)notification {
    self.userInteractionEnabled = [notification.object boolValue];
    if (self.userInteractionEnabled) {
        self.backgroundColor = RGBColor(0, 194, 155);
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = RGBColor(207, 207, 207);
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark - 销毁移除通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setEnableRegisterCell" object:nil];
}

@end
