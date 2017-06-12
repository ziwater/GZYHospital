//
//  ScheduleModel.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "ScheduleModel.h"

@implementation ScheduleModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"ScheduleItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
