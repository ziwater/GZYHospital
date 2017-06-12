//
//  CalendarDemoViewController.h
//  CalendarDemo
//
//  Created by Chris on 15/11/17.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface CalendarViewController : UIViewController <FSCalendarDataSource, FSCalendarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) NSInteger theme;
@property (assign, nonatomic) FSCalendarScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL lunar;
@property (strong, nonatomic) NSDate *selectedDate;
@property (assign, nonatomic) NSUInteger firstWeekday;

@property (strong, nonatomic) NSArray *datesShouldNotBeSelected; //不可选择日期数组
@property (strong, nonatomic) NSMutableArray *datesWithEvent; //有事件日期数组

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)todayItemClicked:(UIBarButtonItem *)sender;
- (IBAction)ScopeChange:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@property (nonatomic, copy) NSString *SyscodeId;
@property (nonatomic, copy) NSString *calendarIdentify;

@end
