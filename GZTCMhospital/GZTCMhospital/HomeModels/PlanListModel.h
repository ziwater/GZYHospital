//
//  PlanListModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/2.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlanListModel : NSObject

@property (nonatomic, copy) NSString *StaticsName;
@property (nonatomic, copy) NSString *SelectSyscodeIDValue;
@property (nonatomic, assign) NSInteger FinishedNum;
@property (nonatomic, assign) NSInteger AllNum;
@property (nonatomic, copy) NSString *Percent;

@end
