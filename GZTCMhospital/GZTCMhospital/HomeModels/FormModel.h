//
//  FormModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FormSecondModel;

@interface FormModel : NSObject

@property (nonatomic, strong) FormSecondModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
