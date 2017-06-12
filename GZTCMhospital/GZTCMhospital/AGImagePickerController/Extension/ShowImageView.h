//
//  ShowImageView.h
//  Demo0819
//
//  Created by Chris on 15/8/19.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^didRemoveImage)();

@interface ShowImageView : UIView //用来处理图片点击后放大的效果

@property (nonatomic,copy)didRemoveImage removeImg;

-(id)initWithFrame:(CGRect)frame byClickTag:(NSInteger)clickTag appendArray:(NSArray *)appendArray;

@end
