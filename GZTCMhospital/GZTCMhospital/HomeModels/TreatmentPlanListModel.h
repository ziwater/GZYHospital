//
//  TreatmentPlanListModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreatmentPlanModel;

//诊疗计划、提醒管理可复用此模型
@interface TreatmentPlanListModel : NSObject

@property (nonatomic, strong) TreatmentPlanModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
