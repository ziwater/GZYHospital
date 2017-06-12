//
//  CourseDataModel.h
//  JsonDemo
//
//  Created by Chris on 15/11/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CourseListModel;

@interface CourseDataModel : NSObject

@property (nonatomic, strong) CourseListModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
