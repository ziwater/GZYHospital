//
//  CourseProgressTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/2.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseProgressTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID;

@property (nonatomic, strong) NSMutableArray *planListModels; //存放PlanListModel类型对象的数组
@property (nonatomic, strong) NSMutableArray *courseProgressListModels;//存放CourseProgressListModel对象的数组

@end
