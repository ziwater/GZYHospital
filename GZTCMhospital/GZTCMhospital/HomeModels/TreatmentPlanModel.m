//
//  TreatmentPlanModel.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "TreatmentPlanModel.h"

@implementation TreatmentPlanModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"TreatmentPlanItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
