//
//  UploadPortraitCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/14.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "UploadPortraitCell.h"

@implementation UploadPortraitCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {  //用户头像自定义布局(设置圆形)
    [super layoutSubviews];
    
    [_portraitImageView.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
    _portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
    _portraitImageView.layer.shadowOpacity = 0.5;
    _portraitImageView.layer.shadowRadius = 2.0;
//    _portraitImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _portraitImageView.layer.borderWidth = 2.0f;
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

@end
