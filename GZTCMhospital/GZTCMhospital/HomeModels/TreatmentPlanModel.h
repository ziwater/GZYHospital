//
//  TreatmentPlanModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatmentPlanModel : NSObject

@property (nonatomic, strong) NSArray *DataList;  //存放TreatmentPlanItemModel模型的数组
@property (nonatomic, strong) NSArray *FieldsRemark;
@property (nonatomic, strong) NSArray *LimitList; //存放LimitListModel模型的数组

@end
