//
//  PatientItemModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/27.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientItemModel : NSObject

@property (nonatomic, copy) NSString *PatientName;
@property (nonatomic, copy) NSString *Mzhzyh;
@property (nonatomic, copy) NSString *Sex;
@property (nonatomic, copy) NSString *Tel;
@property (nonatomic, copy) NSString *CardId;
@property (nonatomic, copy) NSString *Doctor;
@property (nonatomic, copy) NSString *Address;
@property (nonatomic, copy) NSString *Info_oid;
@property (nonatomic, copy) NSString *info_formoid;

@end
