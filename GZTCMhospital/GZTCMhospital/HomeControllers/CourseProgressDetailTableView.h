//
//  CourseProgressDetailTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/9.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseProgressDetailTableView : UITableViewController

@property (nonatomic, strong) NSMutableArray *courseProgressListModels; //存放CourseProgressListModel
@property (nonatomic, copy) NSString *completedCourseSysCodeID;
@property (nonatomic, copy) NSString *tableViewTitle;

@end
