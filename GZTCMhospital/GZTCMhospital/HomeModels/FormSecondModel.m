//
//  FormSecondModel.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "FormSecondModel.h"

@implementation FormSecondModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"FormItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
