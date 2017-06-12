//
//  CourseListModel.m
//  JsonDemo
//
//  Created by Chris on 15/11/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CourseListModel.h"

@implementation CourseListModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"CourseItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
