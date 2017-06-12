//
//  HomeModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/1.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject //第一层

@property (nonatomic, assign) NSInteger retcode;
@property (nonatomic, strong) NSArray *data; //存放HomeSectionModel类型对象

@end
