//
//  PatientModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/27.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PatientSecondModel;

@interface PatientModel : NSObject

@property (nonatomic, strong) PatientSecondModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
