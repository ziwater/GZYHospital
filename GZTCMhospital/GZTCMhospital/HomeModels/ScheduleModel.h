//
//  ScheduleModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleModel : NSObject

@property (nonatomic, strong) NSArray *DataList;  //存放ScheduleItemModel模型的数组
@property (nonatomic, strong) NSArray *FieldsRemark;
@property (nonatomic, strong) NSArray *LimitList; //存放LimitListModel模型的数组

@end
