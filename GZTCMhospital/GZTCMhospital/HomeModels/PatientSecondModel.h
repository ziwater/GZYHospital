//
//  PatientSecondModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/27.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientSecondModel : NSObject

@property (nonatomic, strong) NSArray *DataList;  //存放PatientItemModel模型的数组
@property (nonatomic, strong) NSArray *LimitList; //存放LimitListModel模型的数组

@end
