//
//  OrderResultModel.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "OrderResultModel.h"

@implementation OrderResultModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"DataList" : @"OrderResultItemModel",
             @"LimitList" : @"LimitListModel"
             };
}

@end
