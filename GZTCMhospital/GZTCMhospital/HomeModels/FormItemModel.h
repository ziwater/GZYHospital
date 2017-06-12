//
//  FormModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/14.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormItemModel : NSObject

@property (nonatomic, copy) NSString *Title;
@property (nonatomic, copy) NSString *CreateDateTime;
@property (nonatomic, copy) NSString *FormID;
@property (nonatomic, copy) NSString *OperatorID;
@property (nonatomic, copy) NSString *DetailID;
@property (nonatomic, copy) NSString *StafferName;

@end
