//
//  PatientSecondModel.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/27.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "PatientSecondModel.h"

@implementation PatientSecondModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"PatientItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
