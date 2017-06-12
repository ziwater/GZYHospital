//
//  CourseListTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/1.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseListTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *courseItemModels; //存放CourseItemModel对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addCourseItem;

- (IBAction)addCourseAction:(UIBarButtonItem *)sender;
- (IBAction)deleteCourseAction:(id)sender;
- (IBAction)modifyCourseAction:(id)sender;

- (void)setupRefresh;

@end
