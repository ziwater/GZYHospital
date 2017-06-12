//
//  ScheduleListModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScheduleModel;

@interface ScheduleListModel : NSObject

@property (nonatomic, strong) ScheduleModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
