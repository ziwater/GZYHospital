//
//  DoctorOrNurseListModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/22.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoctorOrNurseListModel : NSObject  //医生、护士公用此模型

@property (nonatomic, copy) NSString *syscodeName;
@property (nonatomic, copy) NSString *syscodeId;

@end
