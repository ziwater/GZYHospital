//
//  HomeSectionModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/1.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeSectionModel : NSObject //第二层

@property (nonatomic, copy) NSString *moduleHeaderTitle;
@property (nonatomic, strong) NSArray *moduleItems; //存放HomeItemModel类型对象

@end
