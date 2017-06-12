//
//  ScheduleTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableView : UITableViewController

@property (nonatomic, copy) NSString *scheduleUrl;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *scheduleItemModels; //存放ScheduleItemModel对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addScheduleItem;

- (IBAction)addScheduleAction:(UIBarButtonItem *)sender;
- (IBAction)modifyScheduleAction:(id)sender;
- (IBAction)deleteScheduleAction:(id)sender;

@end
