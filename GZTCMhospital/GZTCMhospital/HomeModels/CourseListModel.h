//
//  CourseListModel.h
//  JsonDemo
//
//  Created by Chris on 15/11/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseListModel : NSObject

@property (nonatomic, strong) NSArray *DataList;  //存放CourseItemModel模型的数组
@property (nonatomic, strong) NSArray *FieldsRemark;
@property (nonatomic, strong) NSArray *LimitList; //存放LimitListModel模型的数组

@end
